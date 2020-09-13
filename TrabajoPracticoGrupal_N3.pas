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
Opcion:integer;
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
assign(AEnf,'C:/TP3/Enfermedades.dat');
assign(ASint,'C:/TP3/Sintomas.dat');
assign(APac,'C:/TP3/Pacientes.dat');
assign(AHist,'C:/TP3/Historias.dat');
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



Procedure cargar_sint_de_enf(num_enf:integer);
var
i:integer;
existe:boolean;
begin
    for i:= 1 to max_sint do
            begin
                repeat
                matriz_sintomas[num_enf,i]:=cod_str_no_repetido('Ingrese el codigo del sintoma: ',matriz_sintomas[num_enf]);
                existe:=is_in_array(cod_sint,matriz_sintomas[num_enf,i]);
                if existe=false then
                    writeln('El codigo ingresado no existe');
                until existe = true;

                if (i=acum_sint) then
                    begin
                        writeln('No hay mas sintomas');
                        i:=max_sint; //sale del repeat
                    end;

                if (i<max_sint) then
                begin
                    if opcion_binaria('Desea ingresar otro sintoma? (S/N) ','S','N','MAY')= 'N' then
                    i:=max_sint;//sale del repeat
                end;
            end;

end;


Procedure Mostrar_sintomas;   //Este procedure ese para el chapin enfermedades
var i,j,k,acum:integer;
begin
    for i:= 1 to cant_sint do
        begin
            if cod_sint[i]<>null then
            begin
                writeln('El sintoma con el codigo ',cod_sint[i],' es ',desc_sint[i]);
                acum:=0;
                for j:= 1 to cant_enf do
                begin
                    for k:= 1 to high(matriz_sintomas[j]) do
                    begin
                        if (matriz_sintomas[j,k] = cod_sint[i]) then acum:=acum+1;
                    end;
                end;
                writeln('Las enfermedades que la presentan son: ',acum);
            end;
        end;

end;


//MODULOS----------------------------------------------------------------------

//Procedure INICIALIZACION;
//begin
//    CreateDir('D:/TP3');

//    assing (,'TP3/provincias.dat');
//    {$I-}
//    reset();
//    if ioresult=2 then
//        rewrite();
//    {$I+}

//    assing (,'TP3/enfermedades.dat');
//    {$I-}
//    reset();
//    if ioresult=2 then
//        rewrite();
//    {$I+}

//    assing (,'TP3/sintomas.dat');
//    {$I-}
//    reset();
//    if ioresult=2 then
//        rewrite();
//    {$I+}

//    assing (,'TP3/pacientes.dat');
//    {$I-}
//    reset();
//    if ioresult=2 then
//        rewrite();
//    {$I+}

//    assing (,'TP3/historias.dat');
//    {$I-}
//    reset();
//    if ioresult=2 then
//        rewrite();
//    {$I+}


//end;


Procedure Pacientes;        //INGRESO DE PACIENTES
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




Procedure Enfermedades;         //BUSQUEDA DE ENFERMEDADES
var
i:integer;
begin
clrscr;
   for i:=acum_enf+1 to cant_enf do        //ACA CARGAMOS LAS ENFERMEDADES
    begin
        cod_enf[i]:=cod_str_no_repetido('Ingrese el codigo de la enfermedad: ',cod_enf);
        desc_enf[i]:=string_valido('Ingrese el nombre de la enfermedad: ',1,30);
        acum_enf:=acum_enf+1;

        cargar_sint_de_enf(i);//cargamos los sintomas de la enfermedad numero i


        //Preguntamos si quiere ingresar otra enfermedad
        if (i=cant_enf) then writeln('La base de datos esta llena') else
            if opcion_binaria('Desea ingresar otra enfermedad? (S/N) ','S','N','MAY')= 'N' then
                i:=cant_enf;
        writeln;
    end;


    Mostrar_sintomas;



end;



Procedure Sintomas;     //CARGA DE SINTOMAS
var i:integer;
begin
clrscr;
    if (acum_sint=cant_sint) then writeln('La base de datos esta llena');

    for i:= acum_sint+1 to cant_sint do
        begin
            cod_sint[i]:=cod_str_no_repetido('Ingrese el codigo del sintoma: ',cod_sint);
            desc_sint[i]:=string_valido('Ingrese el nombre del sintoma: ',1,30);
            acum_sint:=acum_sint+1;

            if acum_sint<cant_sint then
                begin
                if (opcion_binaria('Desea ingresar otro sintoma? (S/N) ','S','N','MAY') = 'N') then
                    i:=cant_sint;
                end
            else writeln('NO podes ingresar mas sintomas');

            writeln;
        end;

end;



Procedure Provincias;        //CARGA DE PROVINCIAS
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
            writeln('0) Fin del Programa');textcolor(7);
            Opcion:=int_valido('Ingrese la opcion: ',0,6);
            Case Opcion of
            1: Provincias;
            2: Sintomas;
            3: if (acum_sint>0) then Enfermedades else writeln('Todavia no fueron cargados los sintomas');
            4: Pacientes;
            5: writeln('En construccion');
            6: writeln('En construccion');
            0: Andando:=False;
            end;


            writeln;
            if(opcion<>0) then
                begin
                    writeln('Press any key to continue...');readkey;
                    clrscr;
                end;
        end;

//Saludos
textcolor(10);writeln('Gracias por utilizar nuestro software :)');
readkey;
END.
