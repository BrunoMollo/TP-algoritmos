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
cant_provincias=2;
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
           cod_prov:char;
           cant_enf:integer;
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

Function rep_sint(reg:unsintoma;campo:integer):boolean; //ingresa un registro de sintoma y el numeor del campo que qeures chequar (1:cod, 2:desc)
var aux:unsintoma;                                      //Te va a tirar un true si esta repetido el campo, si nada se repita va un false
begin
    rep_sint:=False;
    reset(ASint);

    while not eof(ASint) and not(rep_sint) do
    begin
    read(ASint,aux);
       case campo of
            1:if reg.cod=aux.cod then
                                 rep_sint:=True;
            2:if reg.desc=aux.desc then
                                   rep_sint:=True;
       end;
    end;
end;


Function rep_prov(reg:unaprovincia;campo:integer):boolean; //ingresa un registro de provincia y el numeor del campo que qeures chequar (1:cod, 2:desc)
var aux:unaprovincia;                                      //Te va a tirar un true si esta repetido el campo, si nada se repita va un false
begin
    rep_prov:=False;
    reset(AProv);

    while not eof(AProv) and not(rep_prov) do
    begin
    read(AProv,aux);
       case campo of
            1:if reg.cod=aux.cod then
                                 begin
                                 //writeln('Codigo ya ingresado');
                                 rep_prov:=True;
                                 end;
            2:if reg.desc=aux.desc then
                                   begin
                                   //writeln('Nombre ya ingresado');
                                   rep_prov:=True;
                                   end;
       end;
    end;
end;



Function rep_enf(reg:unaEnfermedad;campo:integer):boolean; //ingresa un registro de enfermedad y el numeor del campo que qeures chequar (1:cod, 2:desc)
var aux:unaEnfermedad;                                      //Te va a tirar un true si esta repetido el campo, si nada se repita va un false
begin
    rep_enf:=False;
    reset(Aenf);

    while not eof(Aenf) and not(rep_enf) do
    begin
    read(Aenf,aux);
       case campo of
            1:if reg.cod=aux.cod then
                                 rep_enf:=True;
            2:if reg.desc=aux.desc then
                                   rep_enf:=True;
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

Procedure borramela; //esto esta para debugear, la idea es que no este en le programa final
begin
writeln('La base de datos ha fallecido');
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
i,cont:integer;
auxiliar:string[3];
dea:unSintoma;

begin
//                  E.sintomas = array [1..max_sint=6]  of string[3]
//      begin
//        seek(AEnf,filepos(AEnf));
       limpiar_str3(reg.sintomas);
        for i:= 1 to max_sint do
        begin
             repeat
             dea.cod:=cod_str_no_repetido('Ingrese el codigo del sintoma: ',reg.sintomas);


             if not rep_sint(dea,1) then writeln('Codigo no existente');
             until rep_sint(dea,1);
             reg.sintomas[i]:=dea.cod;

             if i=filesize(ASint) then i:=max_sint;
             if (i<max_sint) then
                begin
                if opcion_binaria('Desea ingresar otro sintoma? (S/N) ','S','N','MAY')= 'N'then
                i:=max_sint;//sale del repeat
                end;
        end;
writeln(' ');
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

if filesize(AEnf)<>0 then
   begin
   reset(AEnf);
   Writeln('Enfermedades previamente ingresadas: ');
   while not eof(AEnf) do
         begin
         read(AEnf,E);
         writeln(E.cod,'  ',E.desc);
         end;
   writeln('---------------------------------------');
   end;
end;

//MODULOS----------------------------------------------------------------------



Function ExisteDNI(mi_dni:string[8]):boolean;
var fiambre:unpaciente;
begin
    ExisteDNI:=False;
    reset(APac);
    while not eof(APac) do
    begin
        read(APac,fiambre);
        if fiambre.dni=mi_dni then ExisteDNI:=True;
    end;

end;

Function PromEdades:real; //calcula el promedio de edad de TODOS los pacientes;
var suma:real;
    pacAux:unpaciente;
begin
    reset(APac);
    suma:=0;
    while not eof(Apac) do
    begin
        read(Apac,pacAux);
        suma:=suma+pacAux.edad;
    end;
    promEdades:=suma/filesize(APac);
end;





Procedure Pacientes;        //INGRESO DE PACIENTES

var
fiambre,mirta:unpaciente;
auxprov:unaprovincia;


{sanos:integer;}
{curado:char;}
begin
clrscr;
    //El mas viejo va a estar primero, entonces lo bajo
    seek(APac,0);
    if(filesize(APac)<>0) then read(APac,mirta)
    else mirta.edad:=0;



    {sanos:=0; }

    repeat
        writeln;
        //Chequeo que no haya dni repetido
        repeat
            fiambre.dni:=string_num_valido('Ingrese el numero del DNI: ',1,8);
            if ExisteDNI(fiambre.dni) then writeln('Ya ingresaron ese DNI');
        until not ExisteDNI(fiambre.dni);

        fiambre.edad:=int_valido('Ingrese la edad del paciente: ',0,125);

        repeat
            auxprov.cod:=char_valido('Ingrese codigo de provincia: ','A','Z','MAY');
            fiambre.cod_prov:=auxprov.cod;
            if not rep_prov(auxprov,1) then writeln('Esa provincia no existe');
        until rep_prov(auxprov,1);

        fiambre.cant_enf:=0;//Empieza en cero, no???
        fiambre.dead:=opcion_binaria('Esta vivo o Muerto? (M/V) ','M','V','MAY');//hay que preguntar esto o va vivo por defecto????


        {fiambre.curado:=opcion_binaria('Se ha curado? (S/N) ','S','N','MAY');  //Esto todavia hay qeu mostrarlo????
        if curado='S' then
            sanos:=sanos+1;}
        if (filesize(APac)=0) then
        begin
            //Es el mas viejo porqeu llego primero
            mirta.dni:=fiambre.dni;
            mirta.edad:=fiambre.edad;
            mirta.cod_prov:=fiambre.cod_prov;
            mirta.cant_enf:=fiambre.cant_enf;
            mirta.dead:=fiambre.dead;

            write(APac,fiambre);
        end
        else
        begin
            if (fiambre.edad>mirta.edad) then
                begin
                    seek(APac,filesize(APac));
                    write(Apac,mirta);//escribo al destronado al final

                    //Efiambre se confierte en la nueva mirta
                    mirta.dni:=fiambre.dni;
                    mirta.edad:=fiambre.edad;
                    mirta.cod_prov:=fiambre.cod_prov;
                    mirta.cant_enf:=fiambre.cant_enf;
                    mirta.dead:=fiambre.dead;

                    seek(APac,0);
                    write(APac,mirta);//Escribo el nuvo record al principio

                end
            else
                begin
                    seek(APac,filesize(APac));
                    write(Apac,fiambre);
                end;
        end;


    until opcion_binaria('Desea ingresar otro paciente? (S/N) ','S','N','MAY')='N';

    Writeln;Writeln;
    writeln('El promedio de edades de todos los pacientes atendidos es de: ',PromEdades:6:2);
    //writeln('La cantidad de pacientes curados es de: ',sanos);
    writeln('El paciente de mayor edad afectado tiene ',mirta.edad,' y su DNI es ',mirta.dni);
end;




Procedure Enfermedades;         //BUSQUEDA DE ENFERMEDADES    //falta validar codigos y nombres
var
a:boolean;
x:unaEnfermedad;
begin
a:=true;
clrscr;
reset(AEnf);
Mostrar_enfermedades;
seek(AEnf,filesize(AEnf));

while (a) do      //ACA CARGAMOS LAS ENFERMEDADES
      begin
           seek(AEnf,filesize(AEnf));
           repeat
           x.cod:=string_valido('Ingrese el codigo de la enfermedad: ',1,3);
           until not(rep_enf(x,1));
           E.cod:=x.cod;

           repeat
           x.desc:=string_valido('Ingrese el nombre de la enfermedad: ',1,30);
           until not(rep_enf(x,2));
           E.desc:=X.desc;

         sint_enf(E);//cargamos los sintomas de la enfermedad e

           write(AEnf,E);
//         Preguntamos si quiere ingresar otra enfermedad
           if (filesize(AEnf)=cant_enf) then
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
            if rep_sint(X,1) then writeln('Codigo ya existente');
            until not(rep_sint(X,1));
            S.cod:=x.cod;
            repeat
            X.desc:=string_valido('Ingrese el nombre del sintoma: ', 1,20);
            if rep_sint(X,2) then writeln('Nombre ya existente');
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
//-----------------------------------------------------------------------------------
Procedure Ordenar1;
var i,j:integer;
PI,PJ:unaProvincia;
begin
    reset(AProv);
    for i:= 0 to filesize(AProv)-2 do
        for j:= i+1 to filesize(AProv)-1 do
            begin
                seek(AProv,i);
                read(AProv,PI);
                seek(AProv,j);
                read(AProv,PJ);
                if (PI.cod > PJ.cod) then
                    begin
                        seek(AProv,i);
                        write(AProv,PJ);
                        seek(AProv,j);
                        write(AProv,PI);
                    end;
            end;
    reset(AProv);
    for i:= 1 to filesize(AProv) do
        begin
            read(AProv,P);
            writeln(P.cod,'  ','-','  ',P.desc);
        end;
end;

Procedure Ordenar2;
var i,j:integer;
PI,PJ:unaProvincia;
begin
    reset(AProv);
    for i:= 0 to filesize(AProv)-2 do
        for j:= i+1 to filesize(AProv)-1 do
            begin
                seek(AProv,i);
                read(AProv,PI);
                seek(AProv,j);
                read(AProv,PJ);
                if (PI.desc > PJ.desc) then
                    begin
                        seek(AProv,i);
                        write(AProv,PJ);
                        seek(AProv,j);
                        write(AProv,PI);
                    end;
            end;
    reset(AProv);
    for i:= 1 to filesize(AProv) do
        begin
            read(AProv,P);
            writeln(P.cod,'  ','-','  ',P.desc);
        end;
end;


//PROVINCIAS FINAL?
Procedure Provincias;
var i:integer;
begin                           //CARGA DE PROVINCIAS
    reset(AProv);
    If not (filesize(AProv) = cant_provincias) then
    begin
        write('Ingrese los datos de las provincias');
        writeln();writeln();
        for i:= 1 to cant_provincias do
            begin
                repeat
                    P.cod:=char_valido('Codigo de la Provincia: ','A','Z','MAY');
                    if rep_prov(P,1) then writeln('Ya ingresaste ese codigo');
                until not rep_prov(P,1);
                repeat
                    P.desc:=string_valido('Nombre de la provincia: ',1,20);
                    P.desc:=Uppercase(P.desc);
                    if rep_prov(P,2) then writeln('Ya ingresaste ese nombre');
                until not rep_prov(P,2);
                write(AProv,P);
            end;
    end
    else write('Las provincias ya fueron cargadas...');


reset(AProv);
    writeln();
//    write('La cantidad de provincias que empiezan con la letra S es de: ',);   //ACA VA LA FUNCION QUE BUSCA LA LETRA
    writeln();writeln();
    writeln('Codigo de provincias ordenado alfabeticamente');
    Ordenar1;
    writeln();
    writeln('Provincias ordenadas alfabeticamente');
    Ordenar2;


end;
//-----------------------------------------------------------------------------------
{Procedure Provincias;       //CARGA DE PROVINCIAS
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

}
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
            4: if (filesize(AProv)>0)then Pacientes else writeln('Primero vas a tener que  cargar las provincias');
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
