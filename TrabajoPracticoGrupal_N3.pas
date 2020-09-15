Program TrabajoPracticoGrupal_V3;
//******************************************//
//****      Alumnos:                    ****///
//****  -Di Giacinti Ramiro             ****////
//****  -Fernandez Cariaga Ezequiel     ****/////
//****  -Mollo Bruno                    ****//////
//****                                  ****/////
//****      Comision: 107               ****////
//****                                  ****///
//******************************************//

Uses CRT,sysutils;

//Constantes------------------------------------------------------------------------------

Const
cant_provincias=24;
cant_sint=20;
cant_enf=10;
max_sint=6;
null=char(0)+char(0)+char(0);



//Types------------------------------------------------------------------------------

Type
cod=array [1..cant_provincias] of char;
desc=array [1..cant_provincias] of string[20];
cod_sintomas=array [1..cant_sint] of string[3];
desc_sintomas=array [1..cant_sint] of string[30];
cod_enfermedades=array [1..cant_enf] of string[3];
desc_enfermedades=array [1..cant_enf] of string[30];
matriz=array[1..cant_enf,1..max_sint]of string[3];
sintenf = array [1..max_sint] of string[3];


unaProvincia = record
             cod:char;
             desc:string[20];
             end;
unSintoma = record
          cod:string[3];
          desc:string[20];
          end;
unaEnfermedad = record
              cod:string[3];
              desc:string[20];
              sintomas:sintenf;
              end;
unPaciente = record
           DNI:string[8];
           edad:integer;
           cod:char;
           cant:integer;
           dead:char;
           end;
unaHistoria = record
            DNI:string[8];
            cod:string[3];
            curado:char;
           // fecha-ingreso:?;
           // sintomas:array [1..?] of string[3];
            efector:string[30];
            end;

//Variables globales------------------------------------------------------------------------------

VAR
//Para el menu principal
Opcion,h:integer;
Andando:boolean;


//para guardar distintos datos cargados por el usuario
codprov:cod;
detprov:desc;
cod_sint:cod_sintomas;
desc_sint:desc_sintomas;
cod_enf:cod_enfermedades;
desc_enf:desc_enfermedades;
matriz_sintomas:matriz;
P:unaProvincia;
S:unSintoma;
E:unaEnfermedad;
AProv:file of unaProvincia;
ASint:file of unSintoma;
AEnf:file of unaEnfermedad;
APac:file of unPaciente;
AHist:file of unaHistoria;


//para llevar rregistro de qeu tan cargado estan los arrays
acum_sint:integer;
acum_enf:integer;


//Funciones------------------------------------------------------------------------------

Function rep_sint(reg:unsintoma;campo:integer):boolean; //ingresa un registro de provincia y el numeor del campo que qeures chequar (1:cod, 2:desc)
var aux:unsintoma;                                      //Te va a tirar un true si esta repetido el campo, si nada se repita va un false
begin
    rep_sint:=False;
    reset(ASint);

    while not eof(ASint) and not(rep_sint) do
    begin
    read(ASint,aux);
       case campo of
            1:if reg.cod=aux.cod then
                                 begin
                                 writeln('Codigo existente');
                                 rep_sint:=True;
                                 end;
            2:if reg.desc=aux.desc then
                                   begin
                                   writeln('Nombre ya ingresado');
                                   rep_sint:=True;
                                   end;
       end;
    end;
end;


Function string_valido(msn:string; min,max:integer):string;  //FUNCION PARA VALIDAR LOS STRINGS
begin

    repeat
        write(msn);
        readln(string_valido);
        if length(string_valido)<min then
        begin
            write('No podes ingresar menos de ',min);
            if min=1 then
                writeln(' caracter')
            else
                writeln(' carcteres');
        end;

        if length(string_valido)>max then
        begin
            write('No podes ingresar mas de ',max);
            if max=1 then
                writeln(' caracter')
            else
                writeln(' carcteres');
        end;
    until (length(string_valido)>=min) and (length(string_valido)<=max);

end;


Function string_num_valido(msn:string; min,max:integer):string;     //FUNCION PARA VALIDAR STRINGS QUE SON NUMEROS
var
i:integer;
valido:boolean;
begin
    repeat
        string_num_valido:=string_valido(msn, min, max);
        valido:=True;
        for i:= 1 to length(string_num_valido) do
            begin
            if not ((string_num_valido[i]>='0') and (string_num_valido[i]<='9')) then
                valido:=False;
            end;
        if not (valido) then
            writeln(string_num_valido,' no es un numero valido');
    until valido;
end;


Function int_valido(msn:string; min,max:integer):integer;       //FUNCION PARA VALIDAR ENTEROS POSITIVOS
var
str_aux:string;
begin
    repeat
         str_aux:= string_num_valido(msn,1,9);//Si ingrean un numero de mas de 10 dijitos puede cerrarce el programa, ay que no puede guardar enteros atn grandes
         int_valido:= StrToInt(str_aux);
         if (int_valido<min) then
            writeln('El numero tiene que ser mayor que ',min);
         if (int_valido>max) then
            writeln('El numero tiene que ser menor que ',max);
    until ((int_valido>=min) and (int_valido<=max));
end;


Function char_valido(msn:string; min,max:char; modo:string):char;       //FUNCION PARA VALIDAR CARACTERES
var                                                                 //Modo='MAY'--> COnvierte el caracter leido a mayuscula
valido:boolean;                                                     //Modo='MIN'-->Convierte el caracter leido a minuscula
aux:string[1];
begin
    repeat
        aux:=string_valido(msn,1,1);
        if (modo='MAY') then
            aux:=Uppercase(aux);
        if (modo='MIN') then
            aux:=Lowercase(aux);
        char_valido:=aux[1];
        if ((char_valido>=min) and (char_valido<=max)) then
            begin
            valido:= True;
            end
        else
            begin
            valido:= False;
            writeln(char_valido,' no es un caracter valido')
            end;
    until valido=True;
end;


Function opcion_binaria(msn:string; opcA,opcB,modo:string):char;        //FUNCION PARA VALIDAR OPCION ENTRE SEGUIR O NO
var
valido:boolean;
aux:string[1];
begin
    repeat
        aux:=string_valido(msn,1,1);
        if (modo='MAY') then
            aux:=Uppercase(aux);
        if (modo='MIN') then
            aux:=Lowercase(aux);
        opcion_binaria:=aux[1];
        valido:=True;
        if (opcion_binaria<>opcA) and (opcion_binaria<>opcB) then
            begin
              valido:=False;
              writeln(opcion_binaria,' no es una opcion valida');
            end;

    until   valido=True;
end;


Function is_in_array(arr:array of string[3]; cod:string[3]):boolean;        //FUNCION PARA SABER SI UN CODIGO YA ESTA EN UN ARRAY de string de 3
var i:integer;                                                   //Tomamos el parametro 'arr' como un array of string[3] para poder usar la misma funcion con las enfermedades y los sintomas(teneindo en cuanta que altera los indices del arreglo)
begin
    is_in_array:=False;
    for i:= low(arr) to high(arr) do
        begin
            if (arr[i]=cod) then
            begin
                is_in_array:=True;
                i:=high(arr);//Sale del for
            end;
        end;
end;

Function is_in_array(arr:array of char; cod:char):boolean;        //FUNCION PARA SABER SI UN CODIGO YA ESTA EN UN ARRAY de char
var i:integer;
begin
    is_in_array:=False;
    for i:= low(arr) to high(arr) do
        begin
            if (arr[i]=cod) then
            begin
                is_in_array:=True;
                i:=high(arr);//Sale del for
            end;
        end;
end;



Function cod_str_no_repetido(msn:string; arr:array of string[3]):string[3];     //FUNCION PARA VERIFICAR QUE NO SE REPITE UN CODIGO
var                                                                        //Puede ser usado con el codigo de enfermedad y de sintoma ya qeu se toma el aprametro como array of string[3]
aux:string[3];                                                             //El arrego debe ser limpiado antes de usar esta funcion
begin
    repeat
    aux:=string_valido(msn,1,3);
    aux:=Uppercase(aux);
    if (is_in_array(arr,aux)) then
        writeln('Ya ingresaste ',aux);
    until not (is_in_array(arr,aux));
   cod_str_no_repetido:=aux;
end;


Function cod_char_no_repetido(msn:string; arr:array of char):char;     //FUNCION PARA VERIFICAR QUE NO SE REPITE UN CODIGO DE CARACTER
var
aux:char;
begin
    repeat
    aux:=char_valido(msn,'A','Z','MAY');
    if (is_in_array(arr,aux)) then
        writeln('Ya ingresaste ',aux);
    until not (is_in_array(arr,aux));
   cod_char_no_repetido:=aux;
end;



//Procedures------------------------------------------------------------------------------

Procedure boot;
begin
    CreateDir('C:/TP3');

    assign(AProv,'C:/TP3/Provincias.dat');
    {$I-}
    reset(AProv);
    if ioresult=2 then
        rewrite(AProv);
    {$I+}

    assign(AEnf,'C:/TP3/Enfermedades.dat');
    {$I-}
    reset(AEnf);
    if ioresult=2 then
        rewrite(AEnf);
    {$I+}

    assign(ASint,'C:/TP3/Sintomas.dat');
    {$I-}
    reset(ASint);
    if ioresult=2 then
        rewrite(ASint);
    {$I+}

    assign(APac,'C:/TP3/Pacientes.dat');
    {$I-}
    reset(APac);
    if ioresult=2 then
        rewrite(APac);
    {$I+}

    assign(AHist,'C:/TP3/Historias.dat');
    {$I-}
    reset(AHist);
    if ioresult=2 then
        rewrite(AHist);
    {$I+}

end;

Procedure shutdown;
begin
close(AProv);
close(AEnf);
close(ASint);
close(APac);
close(AHist);
end;

Procedure borramela;
begin
Rewrite(AProv);
Rewrite(ASint);
Rewrite(AEnf);
Rewrite(APac);
Rewrite(AHist);
end;

Procedure ordenar_provincias(c:cod; d:desc; modo:integer);        //MUESTRA LAS PROVINICIAS ORDENADAS,
var                                                               //MODO=1 -->ORDENA POR CODIGO  ;  MODO=2 -->ORDENA POR NOMBRE
i,j:integer;
bool_modo_1, bool_modo_2:boolean;
aux1:char;
aux20:string[20];
begin
    for i:=1 to cant_provincias-1 do
        for j:=i+1 to cant_provincias do
        begin
            bool_modo_1:=(modo=1)and(c[i]>c[j]);      //Se hace un intercabio de los dos elementos tomado
            bool_modo_2:=(modo=2)and(d[i]>d[j]);     //si se esta ordenando por el codigo(modo=1) y los codigoas analizados estan desordenados(c[i]>c[j]),
            if (bool_modo_1) or (bool_modo_2) then   //o si se esta ordenando por el nombre(modo=2) y los nombre sanalizaods estan desordenados(d[i]>d[j])
            begin
                //Intercambio en el array del codigo
                aux1:=c[i];
                c[i]:=c[j];
                c[j]:=aux1;
                //Intercambio en el array del nombre
                aux20:=d[i];
                d[i]:=d[j];
                d[j]:=aux20;
            end;
        end;
    //MUESTRA
    for i:= 1 to cant_provincias do
        writeln(c[i],' ------- ',d[i]);
end;


Procedure limpiar_str3(var arr:array of string[3]);     //LIMPIA LOS ARREGLOS
var
i:integer;
begin
    for i:= low(arr) to high(arr) do
        arr[i]:=null;//null son tres caracteres nulos
end;

Procedure limpiar_char(var arr:array of char);     //LIMPIA LOS ARREGLOS
var
i:integer;
begin
    for i:= low(arr) to high(arr) do
        arr[i]:=char(0);
end;



Procedure sint_enf(var reg:unaEnfermedad);
var                                     //ver si hay alguna funcion que me sirva para revisar el array de sintomas
                                        //cod_str_no_repetido?
i:integer;
auxiliar:string[3];

begin
//while not eof(ASint) and (a) do                    E.sintomas = array [1..max_sint=6]  of string[3]
//      begin
        seek(AEnf,filepos(AEnf));
//        limpiar_str3(AEnf.sintomas);
        for i:= 1 to max_sint do
        begin
             repeat
             write('Ingrese el codigo del sintoma: ');
             readln(auxiliar);
             reg.sintomas[i]:=cod_str_no_repetido(auxiliar,reg.sintomas);
             until rep_sint(reg,1);

//             E.sintomas[i]:=standby.cod;

             if (i<max_sint) then
                begin
                if opcion_binaria('Desea ingresar otro sintoma? (S/N) ','S','N','MAY')= 'N' then
                i:=max_sint;//sale del repeat
                end;
        end;
//      end;
end;


{Procedure Mostrar_sintomas;   //Este procedure ese para el chapin enfermedades
var i,j,k,acum:integer;
begin
reset(ASint);
reset(AEnf);
while not eof(ASint) do
      begin
      read(Asint,S);
      writeln('El sintoma con el codigo ',S.cod,' es ',S.desc);
      acum:=0;
      while not eof(AEnf)do
          begin
              read(AEnf,E);
              for i:= 1 to max_sint do
              if (E.sintomas[i]=S.cod) then acum:=acum+1;
          end;
          writeln('Las enfermedades que la presentan son: ',acum);
      end;
end; }

Procedure Mostrar_enfermedades;   //Este procedure ese para el chapin enfermedades
begin
reset(AEnf);
writeln('Enfermedades previamente cargadas: ');
while not eof(AEnf) do
      begin
      read(AEnf,E);
      writeln(E.cod,'  ',E.desc);
      end;
writeln('---------------------------------------');
end;


//MODULOS----------------------------------------------------------------------


Procedure Pacient;        //INGRESO DE PACIENTES
var
DNI,DNImirta:string[8];
edad,sanos,edadrecord:integer;
sumaedades,cantpacientes:real;
curado,reset:char;
begin
clrscr;
    edadrecord:=0;
    cantpacientes:=0;
    sumaedades:=0;
    sanos:=0;
    repeat
        DNI:=string_num_valido('Ingrese el numero del DNI: ',1,8);
        edad:=int_valido('Ingrese la edad del paciente: ',0,125);
        curado:=opcion_binaria('Se ha curado? (S/N) ','S','N','MAY');
        if curado='S' then
            sanos:=sanos+1;
        if edad>edadrecord then
            begin
            edadrecord:=edad;
            DNImirta:=DNI;
            end;
        sumaedades:=sumaedades+edad;
        cantpacientes:=cantpacientes+1;
        reset:=opcion_binaria('Desea ingresar otro paciente? (S/N) ','S','N','MAY');
        writeln;
    until reset='N';


    writeln('El promedio de edades de todos los pacientes atendidos es de: ',sumaedades/cantpacientes:6:2);
    writeln('La cantidad de pacientes curados es de: ',sanos);
    writeln('El paciente de mayor edad afectado tiene ',edadrecord,' y su DNI es ',DNImirta);
end;




Procedure Enfermedades;         //BUSQUEDA DE ENFERMEDADES //falta validar codigos y nombres
var
a:boolean;
begin
a:=true;
clrscr;

Mostrar_enfermedades;
seek(AEnf,filesize(AEnf));
while not eof(ASint) and  (a) do      //ACA CARGAMOS LAS ENFERMEDADES
      begin
      E.cod:=string_valido('Ingrese el codigo de la enfermedad: ',1,3);
      E.desc:=string_valido('Ingrese el nombre de la enfermedad: ',1,30);

      sint_enf(E);//cargamos los sintomas de la enfermedad numero i

      write(AEnf,E);
      //Preguntamos si quiere ingresar otra enfermedad
      if (filepos(AEnf)=cant_enf) then
         writeln('La base de datos esta llena')
      else
          if opcion_binaria('Desea ingresar otra enfermedad? (S/N) ','S','N','MAY')= 'N' then
             a:=false;
      end;
writeln;
end;









Procedure Sintomas;     //CARGA DE SINTOMAS
var
a:boolean;
i:integer;
x:unSintoma;
begin
clrscr;
a:=true;
if filesize(ASint)<>0 then
   begin
   reset(ASint);
   Writeln('Sintomas previamente ingresados: ');
   while not eof(ASint) do
         begin
         read(ASint,S);
         writeln(S.cod,'  ',S.desc);
         end;
   writeln('---------------------------------------');
   end;

if (filesize(ASint)=cant_sint) then writeln('La base de datos esta llena');

    while (not(filesize(ASint)=cant_sint)) and (a) do
        begin
            seek(ASint,filesize(ASint));

            repeat
            X.cod:=string_valido('Ingrese el codigo del sintoma: ',1,3);
            until not(rep_sint(X,1));
            S.cod:=x.cod;
            repeat
            X.desc:=string_valido('Ingrese el nombre del sintoma: ', 1,20);
            until not(rep_sint(X,2));
            S.desc:=x.desc;
            seek(ASint,filepos(ASint));
            write(ASint,S);

            if filesize(ASint)<cant_sint then
                begin
                if (opcion_binaria('Desea ingresar otro sintoma? (S/N) ','S','N','MAY') = 'N') then
                    a:=false;
                end
            else writeln('No se pueden ingresar mas sintomas');

            writeln;
        end;

end;



Procedure Provincias;       //CARGA DE PROVINCIAS
var
acum,i:integer;
begin
clrscr;

    //carga
    acum:=0;
    for i:= 1 to cant_provincias do
        begin
            codprov[i]:= cod_char_no_repetido('Ingrese el codigo de la provincia: ',codprov);
            detprov[i]:= string_valido('Ingresar nombre de la provincia: ',1,20);
            detprov[i]:=Uppercase(detprov[i]);

            if (detprov[i][1]='S') then
                begin
                acum:=acum+1;
                end;

            writeln;
        end;

    //Muestra
    writeln();
    writeln('La cantidad de provincias que empiezan con la letra S es de: ',acum);
    writeln();
    writeln('Codigo de provincias ordenados alfabeticamente');
    ordenar_provincias(codprov,detprov,1);
    writeln();
    writeln('Provincias ordenadas alfabeticamente');
    ordenar_provincias(codprov,detprov,2);

end;


//PROGRAMA PRINCIPAL-----------------------------------------------------------------------------

BEGIN
boot;
    //Inicializacion de vairaibles
    acum_sint:=0;
    acum_enf:=0;
    limpiar_str3(cod_sint);
    limpiar_str3(cod_enf);
    limpiar_char(codprov);

    //Menu principal
    Andando:=True;
    while Andando = True do
        begin
            textcolor(4);writeln('-MENU PRINCIPAL-');
            textcolor(22);
            writeln('1) Provincias');
            writeln('2) Sintomas');
            writeln('3) Enfermedades');
            writeln('4) Pacientes');
            writeln('5) Historias Clinicas');
            writeln('6) Estadisticas');
            writeln('7) Borrar datos');
            writeln('0) Fin del Programa');textcolor(7);
            Opcion:=int_valido('Ingrese la opcion: ',0,7);
            Case Opcion of
            1: Provincias;
            2: Sintomas;
            3: if (filesize(ASint)<>0) then Enfermedades else writeln('Todavia no fueron cargados los sintomas');
            4: Pacient;
            5: writeln('En construccion');
            6: writeln('En construccion');
            7: Borramela;
            0: begin
               Andando:=False;
               shutdown;
               end;
            end;


            writeln;
            if(opcion<>0) then
                begin
                    writeln('Press any key to continue...');readkey;
                    clrscr;
                end;
        end;

//Saludos
for h:= 1 to 5 do
begin
textcolor(h);writeln('Gracias por utilizar nuestro software :)');
end;
readkey;
END.
