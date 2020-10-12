Program TrabajoPracticoGrupal_V3;
//******************************************//
//****      Alumnos:                    ****///
//****  -Di Giacinti Ramiro             ****////
//****  -Fernandez Cariaga Ezequiel     ****/////
//****  -Mollo Bruno                    ****//////
//****                                  ****///////
//****      Comision: 107               ****///////
//****                                  ****//////
//****  -Puccini Martin                 ****/////
//****                                  ****////
//****      Comision: 109               ****///
//******************************************//

// Este alumno se sumo para la version 3

Uses CRT,sysutils;

//Constantes------------------------------------------------------------------------------

Const
cant_provincias=24;
cant_sint=20;
cant_enf=10;
max_sint=6;
sint_por_historia=6;
null=char(0)+char(0)+char(0);



//Types------------------------------------------------------------------------------

Type
cod=array [1..cant_provincias] of char;
cod_sintomas=array [1..cant_sint] of string[3];
cod_enfermedades=array [1..cant_enf] of string[3];



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
              sintomas:array [1..max_sint] of string[3];
              end;
unPaciente = record
           DNI:string[8];
           edad:integer;
           cod_prov:char;
           cant_enf:integer;
           dead:char;
           causa_muerte:string[3];
           end;
unaHistoria = record
            DNI:string[8];
            cod_enf:string[3];
            curado:char;
            fecha_ingreso:TdateTime;
            sintomas:array [1..sint_por_historia] of string[3];
            efector:string[30];
            end;

//-------------------------------------------------
//Variables globales------------------------------------------------------------------------------
//-------------------------------------------------


VAR
//Para el menu principal
q:integer;
Andando:boolean;


//para guardar distintos datos cargados por el usuario
codprov:cod;
cod_sint:cod_sintomas;
cod_enf:cod_enfermedades;

P:unaProvincia;
S:unSintoma;
E:unaEnfermedad;
C:unPaciente;

AProv:file of unaProvincia;
ASint:file of unSintoma;
AEnf:file of unaEnfermedad;
APac:file of unPaciente;
AHist:file of unaHistoria;


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//Funciones----------------------------------------------------------------------------------------------------------------------------------------------------------------
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


Function date_to_str(date:TdateTime):string;
Var YY,MM,DD : Word;
begin
 DeCodeDate (Date,YY,MM,DD);
 date_to_str:=(format ('%d/%d/%d ',[dd,mm,yy]));
end;


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
                                    rep_prov:=True;
                                 end;
            2:if reg.desc=aux.desc then
                                begin
                                    rep_prov:=True;
                                end;
       end;
    end;
end;



Function rep_enf(reg:unaEnfermedad;campo:integer):boolean; //ingresa un registro de enfermedad y el numeor del campo que queres chequar (1:cod, 2:desc)
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

Function rep_pac(reg:unpaciente;campo:integer):boolean; //ingresa un registro de paciente y el numeor del campo que qeures chequar (1:cod, 2:desc)
var aux:unpaciente;                                      //Te va a tirar un true si esta repetido el campo, si nada se repita va un false
begin
    rep_pac:=False;
    reset(Apac);

    while not eof(Apac) and not(rep_pac) do
    begin
    read(Apac,aux);
       case campo of
            1:if reg.dni=aux.dni then
                                 rep_pac:=True;
            end;
    end;
end;

Function nomb_sint(cod:string[3]):string;  //le das un codigo y devuelve el nombre del sintoma en cuestion
var mi_sint:unSintoma;
begin
    reset(Asint);
    nomb_sint:='/nombre_no_encontrado/';
    repeat
        read(Asint,mi_sint);
        if mi_sint.cod=cod then nomb_sint:=mi_sint.desc;
    until eof(Asint) or (mi_sint.cod=cod);
end;

Function nomb_enf(cod:string[3]):string;  //le das un codigo y devuelve el nombre de la enfermedad en cuestion
var mi_enf:unaEnfermedad;
begin
    reset(Aenf);
    nomb_enf:='/nombre_no_encontrado/';
    repeat
        read(Aenf,mi_enf);
        if mi_enf.cod=cod then nomb_enf:=mi_enf.desc;
    until (eof(Aenf)) or (mi_enf.cod=cod);
end;



Procedure Mostrar_sint(cod:string[3]);
var mi_enf:unaEnfermedad;
    i:integer;
begin
    reset(Aenf);

    repeat
        read(Aenf,mi_enf);
        if mi_enf.cod=cod then
        begin
            writeln('Los sintomas de la enfermedad son:');
            for i:=1 to max_sint do
            begin
                if mi_enf.sintomas[i]<>null then writeln('-',nomb_sint(mi_enf.sintomas[i]));
            end;
        end;

    until eof(Aenf)or (mi_enf.cod=cod);
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


Function TotalCurados:integer;  //Muestra el total de historias clinicas cuyo paciente sa ha curado
var h:unahistoria;
begin
    TotalCurados:=0;
    reset(Ahist);
    while not eof(Ahist) do
    begin
        read(Ahist,h);
        if h.curado='S' then TotalCurados:=TotalCurados+1;
    end;
end;


//Los is_in_array--#################################################################################################################################


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

//Funciones de validacion-###################################################################################################################################

Procedure MostrarError(m:string);
begin
    ClrEol;
    textcolor(red);
    writeln(m);
    textcolor(LightGray);
    gotoxy(1,whereY-2);
    ClrEol;
end;


Function string_valido(msn:string; min,max:integer):string;  //FUNCION PARA VALIDAR LOS STRINGS
begin

    repeat
        write(msn);
        readln(string_valido);
        ClrEol;//Limpio la linea sigueinte por si hay algun mensaje de error en rojo
        if length(string_valido)<min then
        begin

            if min=1 then
                MostrarError('No podes ingresar menos de 1 caracter')
            else
                MostrarError('No podes ingresar menos de '+intTOStr(min)+' caracteres');
        end;

        if length(string_valido)>max then
        begin
            if max=1 then
                MostrarError('No podes ingresar mas de 1 caracter')
            else
                MostrarError('No podes ingresar mas de '+inttostr(max)+' caracteres');
        end;
    until (length(string_valido)>=min) and (length(string_valido)<=max);
    string_valido:=Uppercase(string_valido);
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
            MostrarError(string_num_valido+' no es un numero valido');
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
            MostrarError('El numero tiene que ser mayor que '+intTostr(min));
         if (int_valido>max) then
            MostrarError('El numero tiene que ser menor que '+intTostr(max));
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
            MostrarError(char_valido+' no es un caracter valido')
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
              MostrarError(opcion_binaria+' no es una opcion valida');
            end;

    until   valido=True;
end;


Function cod_str_no_repetido(msn:string; arr:array of string[3]):string[3];     //FUNCION PARA VERIFICAR QUE NO SE REPITE UN CODIGO
var                                                                        //Puede ser usado con el codigo de enfermedad y de sintoma ya qeu se toma el aprametro como array of string[3]
aux:string[3];                                                             //El arrego debe ser limpiado antes de usar esta funcion
begin
    repeat
    aux:=string_valido(msn,1,3);
    aux:=Uppercase(aux);
    if (is_in_array(arr,aux)) then
        MostrarError('Ya ingresaste '+aux);
    until not (is_in_array(arr,aux));
   cod_str_no_repetido:=aux;
end;


Function pedirFecha:TdateTime;
var d,m,a:integer;
begin
    repeat
        d:=int_valido('Ingresar dia: ',1,31);
        m:=int_valido('Ingresar mes: ',1,12);
        a:=int_valido('Ingresar a'+char(164)+'os: ',1900,2100);
        pedirFecha:=encodeDate(a,m,d);
        if date_to_str(pedirFecha)<>format ('%d/%d/%d ',[d,m,a]) then writeln(format ('%d/%d/%d ',[d,m,a]),' no existe');
        if pedirFecha>date then writeln('NO llegamos a esa fecha todavia');
    until (pedirFecha<=date)and(date_to_str(pedirFecha)=format ('%d/%d/%d ',[d,m,a]));
end;


//Procedures--###########################################################################################################################################################

Procedure boot;
const dir='C:/TP3';//Carpeta conde se va an a guardar los .dat
begin
    CreateDir(dir);

    assign(AProv,dir+'/Provincias.dat');
    {$I-}
    reset(AProv);
    if ioresult=2 then
        rewrite(AProv);
    {$I+}

    assign(AEnf,dir+'/Enfermedades.dat');
    {$I-}
    reset(AEnf);
    if ioresult=2 then
        rewrite(AEnf);
    {$I+}

    assign(ASint,dir+'/Sintomas.dat');
    {$I-}
    reset(ASint);
    if ioresult=2 then
        rewrite(ASint);
    {$I+}

    assign(APac,dir+'/Pacientes.dat');
    {$I-}
    reset(APac);
    if ioresult=2 then
        rewrite(APac);
    {$I+}


    assign(AHist,dir+'/Historias.dat');
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
if opcion_binaria('ESTAS SEGURO???','S','N','MAY')='S' then
begin
    writeln('La base de datos ha fallecido');
    Rewrite(AProv);
    Rewrite(ASint);
    Rewrite(AEnf);
    Rewrite(APac);
    Rewrite(AHist);
end;
end;

Procedure mostrar_cosas;
var elec:string;i,j:integer;
    Prov:unaProvincia;
    Sint:unSintoma;
    Enf:unaEnfermedad;
    Pac:unPaciente;
    Hist:unaHistoria;
begin
    elec:=string_valido('codigo de la bdb: ',0,20);
    ClrScr;
    for i:=1 to length(elec) do
    begin
        case elec[i] of
        '1':begin
                writeln('Provincias');
                reset(Aprov);
                while not eof(AProv) do
                begin
                    read(AProv,Prov);
                    writeln(Prov.cod,' - ',Prov.desc);
                end;
            end;
        '2':begin
                writeln('Sintomas');
                reset(Asint);
                while not eof(Asint) do
                begin
                    read(Asint,sint);
                    writeln(sint.cod,' - ',sint.desc);
                end;
            end;
        '3':begin
                writeln('Enfermedades');
                reset(Aenf);
                while not eof(Aenf) do
                begin
                    read(Aenf,enf);
                    write(enf.cod,' - ',enf.desc,' - [');
                    for j:=1 to max_sint do write(enf.sintomas[j],', ');
                    writeln(']');
                end;
            end;
        '4':begin
                writeln('Pacientes');
                reset(Apac);
                while not eof(Apac) do
                begin
                    read(Apac,pac);
                    writeln(pac.dni,' - ',pac.edad,' - ',pac.cod_prov,' - ',pac.cant_enf,' - ',pac.dead,' - ',pac.causa_muerte);
                end;
            end;
        '5':begin
                writeln('Historias clinicas');
                reset(Ahist);
                while not eof(Ahist) do
                begin
                    read(Ahist,hist);
                    write(hist.dni,' - ',hist.cod_enf,' - ',hist.curado,' - (',date_to_str(hist.fecha_ingreso),') - [');
                    for j:=1 to sint_por_historia do write(hist.sintomas[j],', ');
                    writeln('] - ',hist.efector);
                end;
            end;
        end;
        writeln;
    end;

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


Procedure sint_enf(var arr:array of string[3]);//capas que tendraimos que cambairle el nombre a este procedure, ahora se usa en hiitorias tmb
var                                     //ver si hay alguna funcion que me sirva para revisar el array de sintomas
                                        //cod_str_no_repetido?
i:integer;
SintAux:unSintoma;

begin
//                  E.sintomas = array [1..max_sint=6]  of string[3]
//      begin
//        seek(AEnf,filepos(AEnf));
       limpiar_str3(arr);
        for i:= low(arr) to high(arr) do
        begin
             repeat
                SintAux.cod:=cod_str_no_repetido('Ingrese el codigo del sintoma: ',arr);
                if not rep_sint(SintAux,1) then MostrarError('Codigo no existente');
             until rep_sint(SintAux,1);
             arr[i]:=SintAux.cod;

             if i=high(arr) then writeln('NO se pueden registrar mas de ',i+1,' sintomas');
             if i=filesize(ASint)-1  then
             begin
                i:=high(arr);
                writeln('NO hay mas sintomas para cargar');
             end
             else if (i<high(arr)) then
                begin
                if opcion_binaria('Desea ingresar otro sintoma? (S/N) ','S','N','MAY')= 'N'then
                i:=high(arr);//sale del repeat
                end;
        end;
writeln(' ');
end;


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


Procedure Resumen_sint;
var i,acum:integer;
X:unSintoma;
Y:unaEnfermedad;
begin
reset(ASint);
     while not eof(ASint) do
           begin
           acum:=0;
           read(ASint,X);
           reset(AEnf);
           while not eof(AEnf) do
                 begin
                 read(AEnf,Y);
                 for i:=1 to max_sint do
                     if X.cod = Y.sintomas[i] then
                     acum:=acum+1;
                 end;
           writeln('El sintoma ',x.desc,', codigo ',x.cod,' es presentado por ',acum,' enfermedades');
           Writeln('----------------------------------------------------------------------------------');
           end;
end;

Procedure Enf_prom;
var edades,cont:integer;
X:unPaciente;
Y:unaEnfermedad;
Z:unaHistoria;
begin
reset(AEnf);
while not eof(AEnf) do
begin
      edades:=0;
      cont:=0;
      read(AEnf,Y);

      reset(AHist);           //ok
      while not eof (AHist) do
            begin
                 read(AHist,Z);
                      if Z.cod_enf = Y.cod then
                      begin
                           reset(APac);
                           repeat
                           read(APac,X);
                           until Z.dni = X.dni;
                           edades:=edades+X.edad;
                           cont:=cont+1;
                      end;
            end;
      if cont<>0 then
        begin
        writeln('El promedio de pacientes con la enfermedad: ',Y.desc,' fue de ',edades/cont:6:1);
        Writeln('----------------------------------------------------------------------------------');
        end;
end;
end;

Procedure orden_por_edad;
var
A, B: unPaciente;
i, j: integer;
begin
reset(Apac);
for i:= 0 to filesize(Apac) - 2 do
    for j:= i+1 to filesize(Apac)-1 do
        begin
             seek(APac, i);
             Read(APac, A);
             seek(APac, j);
             Read(APac, B);
             if A.edad < B.edad then
                    begin
                         seek(APac, i);
                         Write(APac, B);
                         seek(APac, j);
                         Write(APac, A);
                    end;
        end;
end;

//--------------------------------------------------------------------------------

Procedure mostrar_mirta;
var
P1, P2: unPaciente;
cum: integer;
i: integer;
begin
    reset(APac);
    if filesize(APac) = 1 then
        begin
        read(APac,P1);
        writeln('El paciente con el DNI ',P1.DNI,' es el mayor con ',P1.edad,' a',char(164),'os');
        end
    else
    begin
    cum := 1;
    reset(APac);
    Read(APac, P1);
    repeat
    read(APac,P2);
    if  P1.edad = P2.edad then cum:=cum+1;
    until (P1.edad <> P2.edad) or EOF(APac);

    Reset(APac);
    if cum <> 1 then
    begin
        Write('Los pacientes con el DNI ');
        for i:= 0 to cum - 1 do
            begin
                 Read(APac, p1);
                 Write(P1.DNI);
                 if i <> cum -2 then
                    begin
                         if i = cum - 1 then
                            begin
                            write('');
                            end
                            else
                            begin
                                 write(', ');
                            end;
                    end
                    else
                    begin
                      write(' y ');
                    end;
            end;

        Writeln(' son los mayores con ', p1.edad,' a',char(164),'os');
    end
    else
    begin
        Writeln('El paciente con el DNI ', P1.DNI, ' es el mayor con ', P1.edad,' a',char(164),'os');
    end;
    end;
end;


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//################################################################################################################################################
//MODULOS----------------------------------------------------------------------
//################################################################################################################################################
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


Procedure Pacientes;        //INGRESO DE PACIENTES
var
fiambre:unpaciente;
auxprov:unaprovincia;

begin
clrscr;

    repeat
        clrscr;
        //Chequeo que no haya dni repetido
        repeat
            fiambre.dni:=string_num_valido('Ingrese el numero del DNI: ',1,8);
            if rep_pac(fiambre,1) then MostrarError('Ya ingresaron ese DNI');
        until not rep_pac(fiambre,1);

        fiambre.edad:=int_valido('Ingrese la edad del paciente: ',1,125);

        repeat
            auxprov.cod:=char_valido('Ingrese codigo de provincia: ','A','Z','MAY');
            fiambre.cod_prov:=auxprov.cod;
            if not rep_prov(auxprov,1) then MostrarError('Esa provincia no existe');
        until rep_prov(auxprov,1);

        fiambre.cant_enf:=0;//Empieza en cero, no???
        fiambre.dead:=opcion_binaria('Esta vivo o Muerto? (M/V) ','M','V','MAY');//hay que preguntar esto o va vivo por defecto????
        fiambre.causa_muerte:=null;
        seek(Apac,filesize(Apac));
        write(Apac,fiambre);


    until opcion_binaria('Desea ingresar otro paciente? (S/N) ','S','N','MAY')='N';
    writeln();

    orden_por_edad;

    Writeln;
    writeln('El promedio de edades de todos los pacientes atendidos es de: ',PromEdades:6:2);
    writeln('Ya se han curado ',TotalCurados,' pacientes');
    orden_por_edad;
    mostrar_mirta;
end;


//                                                                                          #######################################################################
//##################################################################################################################//////////////////////////////////////////////////
//                                                                                          #######################################################################

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
           //clrscr;
           seek(AEnf,filesize(AEnf));
           repeat
                x.cod:=string_valido('Ingrese el codigo de la enfermedad: ',1,3);
                if rep_enf(x,1) then MostrarError('Ya se cargo ese codigo');
           until not(rep_enf(x,1));
           E.cod:=x.cod;

           repeat
                x.desc:=string_valido('Ingrese el nombre de la enfermedad: ',1,30);
                if rep_enf(x,2) then MostrarError('Ya hay una enfermedad con ese nombre');
           until not(rep_enf(x,2));
           E.desc:=X.desc;

         sint_enf(E.sintomas);//cargamos los sintomas de la enfermedad e

           write(AEnf,E);
//         Preguntamos si quiere ingresar otra enfermedad
           if (filesize(AEnf)=cant_enf) then
              writeln('La base de datos esta llena')
           else
               if opcion_binaria('Desea ingresar otra enfermedad? (S/N) ','S','N','MAY')= 'N' then
                  a:=false;

      end;
      writeln('');
      resumen_sint;

end;


//                                                                                          #######################################################################
//##################################################################################################################//////////////////////////////////////////////////
//                                                                                          #######################################################################



Procedure Sintomas;     //CARGA DE SINTOMAS
var
a:boolean;
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
                if rep_sint(X,1) then MostrarError('Codigo ya existente');
            until not(rep_sint(X,1));
            S.cod:=x.cod;
            repeat
                X.desc:=string_valido('Ingrese el nombre del sintoma: ', 1,20);
                if rep_sint(X,2) then MostrarError('Nombre ya existente');
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




//                                                                                          #######################################################################
//##################################################################################################################//////////////////////////////////////////////////
//                                                                                          #######################################################################


Procedure Busqueda_Letra;
var acum:integer;
begin
    reset(AProv);
    acum:=0;
    while not EOF(AProv) do
        begin
            read(AProv,P);
            if P.desc[1] = 'S' then
                acum:=acum+1;
        end;
writeln('La cantidad de provincias que empiezan con la letra S es de: ',acum);
end;

Procedure Ordenar(modo:integer);
var i,j:integer;
PI,PJ:unaProvincia;
banana:boolean;
begin
    reset(AProv);
    for i:= 0 to filesize(AProv)-2 do
        for j:= i+1 to filesize(AProv)-1 do
            begin
                seek(AProv,i);
                read(AProv,PI);
                seek(AProv,j);
                read(AProv,PJ);
                banana:=False;
                case modo of
                1: if (PI.cod > PJ.cod) then banana:=True;
                2: if (PI.desc > PJ.desc) then banana:=True;
                end;
                if (banana) then
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

//PROVINCIAS FINAL      ----MODULO----
Procedure Provincias;
var i:integer;
begin                           //CARGA DE PROVINCIAS
    clrscr;
    reset(AProv);
    If (filesize(AProv) < cant_provincias) then
    begin
        write('Ingrese los datos de las provincias');
        writeln();writeln();
        for i:= filesize(AProv) to cant_provincias-1 do
            begin
                repeat
                    seek(AProv,i);
                    P.cod:=char_valido('Codigo de la Provincia: ','A','Z','MAY');
                    if rep_prov(P,1) then MostrarError('Ya ingresaste ese codigo');
                until not rep_prov(P,1);
                repeat
                    P.desc:=string_valido('Nombre de la provincia: ',1,20);
                    P.desc:=Uppercase(P.desc);
                    if rep_prov(P,2) then MostrarError('Ya ingresaste ese nombre');
                until not rep_prov(P,2);
                write(AProv,P);
            end;
    end
    else write('Las provincias ya fueron cargadas...'); writeln();


reset(AProv);
    writeln();
    Busqueda_Letra;
    writeln();
    writeln('Presione cualquier tecla para ver las provincias ordenadas por codigo alfabeticamente');readkey();
    clrscr;
    writeln('Codigo de provincias ordenado alfabeticamente');
    Ordenar(1);
    writeln();
    writeln('Presione cualquier tecla para ver las provincias ordenadas por nombre alfabeticamente');readkey();
    clrscr;
    writeln('Provincias ordenadas alfabeticamente');
    Ordenar(2);

end;

//-----------------------------------------------------------------------------------------------------

Procedure Provincia_con_mas_enfermos();
var i,j,k,l,m:integer;
indice,indicex,acum2,acum:integer;
codprov:array [1..cant_provincias] of char;
cont_provincia:array[1..cant_provincias]of integer;
begin
    reset(APac);
    reset(AProv);
    for k:= 1 to filesize(AProv) do                  //SE PASA A UN ARRAY LAS PROVINCIAS
        begin
        read(AProv,P);
        codprov[k]:=P.cod;
        cont_provincia[k]:=0;
        end;

    for i:= 1 to filesize(APac) do                 //SE VA SUMANDO LA CANTIDAD DE ENFERMOS POR PROVINCIAS EN EL ARRAY AUXILIAR
        begin
            read(APac,C);
            for j:= 1 to cant_provincias do
                begin
                    if (C.cod_prov = codprov[j]) then
                        cont_provincia[j]:=cont_provincia[j] + 1;
                end;
        end;

    acum:=0;
    for l:= 1 to cant_provincias do               //BUSCO LA MAYOR Y GUARDO LA LETRA
        begin
            if (cont_provincia[l]>acum) then
                begin
                acum:=cont_provincia[l];
                indice:=l;
                end;
        end;

    acum2:=0;
    for m:= 1 to cant_provincias do                //BUSCO SI HAY OTRA QUE SEA IGUAL Y ESTE EMPATADA
        begin
            if (acum = cont_provincia[m]) then
                begin
                acum2:=cont_provincia[m];
                indicex:=m;
                end;
        end;

   writeln('La provincia con mas enfermos es la provincia con codigo ',codprov[indice]);
   if (acum2<>0) and not (indicex = indice) then writeln('Y esta empatada con la provincia con codigo ',codprov[indicex]);



end;


Procedure IngresadosFecha;
var Auxhist:unaHistoria;
    hay_algo:boolean;
    pedida:TdateTime;
begin
    pedida:=pedirFecha;

    writeln();
    writeln('------------------------------------');
    writeln('  DNI  ','      ','Nombre de la enfermedad');
    writeln('------------------------------------');

    reset(Ahist);
    hay_algo:=False;
    while not eof(Ahist) do
    begin
        read(Ahist,Auxhist);
        if auxhist.fecha_ingreso=pedida then
        begin
            hay_algo:=True;
            writeln(Auxhist.dni,' ',' - ',' ',nomb_enf(Auxhist.cod_enf));
        end;
    end;
    if not hay_algo then writeln('Parece que ningun paciente fue ingresado en esta fecha...');

end;


//..........................................................................
Procedure muertos_por_enf;
var
enf: string[20];
cum: integer;
P:unPaciente;
E:unaEnfermedad;

begin
cum := 0;
reset(APac);
reset(AHist);
reset(AEnf);

enf:=string_valido('Ingese el codigo de la enfermedad: ',1,3);                     //ingresa el nombre de la enf

E.cod:=enf;
if not rep_enf(E,1) then writeln('La enfermeddad no esta registrada')
else
begin

reset(Apac);
while not eof(Apac) do
begin
    read(Apac,P);
    if P.causa_muerte=enf then cum:=cum+1;
end;




//if eof(AEnf) then Writeln('La enfermedad ', enf, ' no ha sido registrada');                            //no encontro una enfermedad que se llame igual
//if eof(AHist) and (cum = 0) then Writeln('Ningun paciente contrajo la enfermedad ', enf);                //no encontro una historia clinica con esa enfermedad
if cum = 0 then Writeln ('Ningun paciente con la enfermedad ', enf, ' ha muerto');                      //no encontro ningun muerto
if cum > 1 then Writeln(cum, ' pacientes han muerto de la enfermedad ', enf);
if cum = 1 then Writeln(cum, ' paciente ha muerto de la enfermedad ', enf);
end;


end;
//...........................................................................


Procedure nombre_efectores;
var
nom: string[30];
cum: integer;
H:unaHistoria;
begin
cum := 0;
reset(AHist);
nom:=string_valido('Ingese el nombre del efector: ',1,30);
while not eof(AHist) do
begin
     read(AHist,H);
     if H.efector = nom then
        begin
          cum := cum + 1;
        end;
end;
if cum <> 0 then
begin
Writeln('El efector ', nom, ' atendio a ', cum, ' pacientes');
end
else
begin
Writeln('El efector no existe o no atendio a ningun paciente');
end;

end;


Procedure curados_por_enf;
var
cumAT, cumCU: integer;
H:unaHistoria;
E:unaEnfermedad;

begin;
reset(AEnf);
While not eof(AEnf) do                                                              //Cada enfermedad
      begin
           Read(AEnf, E);
           reset(AHist);
           cumAT:= 0;
           cumCU:= 0;
           While not eof(AHist) do                                                  //Pacientes atendidos
                 begin
                      Read(AHist, H);
                      if E.cod = H.cod_enf then
                         begin
                              cumAT:= cumAT + 1;                                     //Si encuentra el mismo codigo el la historia se atendio al paciente
                              if H.curado = 'S' then cumCU:= cumCU + 1;
                         end
                         else
                 end;
           if cumAT = 0 then                                                                   //no encontro nadie con la enfermedad actual
              begin
                   Writeln('Ningun paciente atendido contrajo la enfermedad ', E.desc);
              end
              else
              begin
           if cumAT = 1 then
              begin
                   write(cumAT, ' paciente contrajo la enfermedad ', E.desc);
                   if cumCU = 0 then
                      begin
                           writeln(' pero no se ha curado');
                      end
                      else
                      begin
                           writeln(' y se ha curado');
                      end;
              end
              else
              begin
                   write(cumAT, ' pacientes contrajeron la enfermedad ', E.desc);
                   if cumCU = 0 then
                      begin
                           writeln(' pero ninguno se ha curado');
                      end
                      else
                      begin
                           writeln(' y ', cumCU, ' se han curado');
                      end;
              end;
              end;
              Writeln('----------------------------------------------------------------------------------');
      end;
end;


//-----------------------------------------------------------------------------------------------------------
Procedure Estadisticas();
var
working:boolean;
choice:integer;
begin
    working:=True;
    writeln();
    while working= True do
        begin
            clrscr;
            writeln('ESTADISTICAS');
            writeln('-------------');
            writeln();
            writeln('1) Enfermedades por sintomas');
            writeln('2) Promedio de edad por enfermedad');
            writeln('3) Pacientes atendidos y curados por enfermedad');
            writeln('4) Quien fue el mayor atendido y cual es su edad');
            writeln('5) Cual fue la provincia que mas enfermos atendio');
            writeln('6) Pacientes ingresados en una fecha');
            writeln('7) Personas fallecidas por una enfermedad');
            writeln('8) Pacientes atendidos por un efector');
            writeln('0) Salir');
            writeln();
            choice:=int_valido('Ingrese la opcion: ',0,8);
            if choice <> 0 then clrscr;
            Case choice of

            1:if (filesize(ASint)=0) then
               writeln('No hay sinomas cargados')
            else

                     if (filesize(AEnf)=0) then
                        writeln('No hay enfermedades cargadas')
                     else
                         Resumen_sint;

            2: if (filesize(AEnf)=0) then
               writeln('No hay enfermedades cargadas')
            else
                begin
                     if (filesize(APac)=0) then
                        writeln('No hay pacientes cargados')
                     else
                         if (filesize(AHist)=0) then
                            writeln('No hay historias cargadas')
                         else
                         enf_prom;
                end;
            3: if(filesize(AEnf)>0)then curados_por_enf else writeln('No hay enfermedades cargadas');

            4: if(filesize(Apac)>0)then mostrar_mirta else writeln('No hay pacientes cargados');
            5: if(filesize(Apac)>0)then Provincia_con_mas_enfermos else writeln('No hay pacientes cargados');  //Si hay pacientes, hay provincias
            6: if(filesize(Ahist)>0)then  IngresadosFecha else writeln('No hay historias clinicas cargadas');
            7: if(filesize(Ahist)>0)then muertos_por_enf else writeln('No hay historias clinicas cargadas');
            8: if(filesize(Ahist)>0)then nombre_efectores  else writeln('No hay efectores cargados');
            0: working:=False;
            end;
           if(choice<>0) then
                begin
                    writeln();
                    writeln('Press any key to continue...');readkey;
                end;

        end;

end;


//                                                                                          #######################################################################
//##################################################################################################################//////////////////////////////////////////////////
//                                                                                          #######################################################################
Function Agregar_enfermedad(DNI:string[8]; enf:string[3]):boolean;
var P:unPaciente;
begin

    P.dni:='banana';//NO hay ningun dni con letras, no introduzca 'banana' como parametro porfa
    reset(APac);
    while (not eof(APac)) and (P.dni<>DNI) do
    begin
        read(Apac,P);
        if P.dni=DNI then
        begin
            P.cant_enf:=P.cant_enf+1;

            textcolor(red);
            if P.causa_muerte<>null then writeln('AVISO: ESTE PACIENTE YA HA FALLECIDO POR LA ENFERMEDAD ',P.causa_muerte,', PUEDE LLEGAR A SOBREESCRIBIR DATOS')
            else if P.dead='M' then writeln('AVISO: EL PACEINTE YA ESTA MUERTO');
            textcolor(7);

            if opcion_binaria('Ha muerto por esta enfermedad?(S/N): ','S','N','MAY')='S' then
                begin
                    P.causa_muerte:=enf;
                    P.dead:='M';
                    Agregar_enfermedad:=false;
                end
                else Agregar_enfermedad:=true;


            seek(Apac,filepos(Apac)-1);
            write(Apac,p);
        end;
    end;
end;


//------------------------------------------------------------------------------------------------------------

Procedure historias;
var auxPac:unpaciente;
    auxEnf:unaEnfermedad;
    auxHist:unahistoria;
    seguir:char;
begin
    clrscr;
    seguir:='S';


    //Pido el DNI
    repeat
    auxPac.dni:=string_num_valido('Ingrese el numero del DNI: ',1,8);
    if not rep_pac(auxPac,1) then
    begin
        writeln('NO tenemos registrado ese dni');
        seguir:=opcion_binaria('Quiere volvear a intentar?(S/N): ','S','N','MAY');
    end;
    until (rep_pac(auxPac,1)) or (seguir='N');




    //Pido el codigo de la enfermedad
    if rep_pac(auxPac,1) and (seguir='S') then
    begin
        repeat
            auxEnf.cod:=string_valido('Ingrese el codigo de la enfermedad: ',1,3);
            if not rep_enf(auxEnf,1) then
            begin
                writeln('NO tenemos registrado esa enfermedad');
                seguir:=opcion_binaria('Quiere volvear a intentar?(S/N): ','S','N','MAY')
            end;
        until (rep_enf(auxEnf,1)) or (seguir='N');




        //pido resto de los datos
        if rep_enf(auxEnf,1) and (seguir='S') then
            begin
                auxHist.dni:=auxPac.dni;
                auxHist.cod_enf:=auxEnf.cod;


                if Agregar_enfermedad(auxHist.dni,auxHist.cod_enf) then
                    auxHist.curado:=opcion_binaria('Se ha curado?(S/N): ','S','N','MAY')
                else
                    auxHist.curado:='N';

                writeln;
                Mostrar_sint(auxHist.cod_enf);

                writeln;
                writeln('Ingresar sintomas que presento el paciente');
                sint_enf(auxHist.sintomas);

                auxHist.efector:=string_valido('Nombre del efector: ',1,30);


                auxHist.fecha_ingreso:=pedirFecha;
                {auxHist.fecha_ingreso:=date();
                writeln;
                writeln('Se ha registrado esta histoira clinica con la fecha ',date_to_str(auxHist.fecha_ingreso));}

                seek(Ahist,filesize(Ahist));
                write(Ahist,auxHist);

                writeln;
                if opcion_binaria('Desea ingresar otro historia clinica?(S/N)','S','N','MAY')='S' then historias;
            end;
    end;



end;


//...................................................................................................................................................
//###########################################################################################################################################
//...............................................................................................................

const
cant_opciones=6;//No cuenta salir
enter=char(13);
arriba=char(80);
abajo=char(72);
type
arr_opc=array[0..cant_opciones] of string[2];



procedure mover_flecha(var op:arr_opc; pos:integer);
var i:integer;
begin
    for i:=0 to cant_opciones do op[i]:='  ';
    op[pos]:='<-';
end;


procedure detectar_flechas(var x:integer;elegida:char;min,max:integer);
begin
          //0->1->4->3->2->1->0
          if (elegida=arriba)or (elegida='s') or (elegida='S') then
          begin
             x:=x+1;
             if x>max then x:=min;
          end
          //1->2->3->4->1
          else if (elegida=abajo) or (elegida='w') or (elegida='W')  then
          begin
             x:=x-1;
             if x<min then x:=max;
          end;
end;


function menu_copado:integer;
var
op:arr_opc;
pos_actual:integer;
elegida:char;
begin
    pos_actual:=1;

    repeat
        textcolor(4);writeln('MENU PRINCIPAL');
        writeln('---------------');textcolor(22);
        writeln();
         mover_flecha(op,pos_actual);
          writeln('Provincias ',op[1]);
          writeln('Sintomas ',op[2]);
          writeln('Enfermedades',op[3]);
          writeln('Pacientes ',op[4]);
          writeln('Historias clinicas ',op[5]);
          writeln('Estadisticas',op[6]);
          writeln('Salir ',op[0]);
          textcolor(7);

          elegida:=readkey;
          detectar_flechas(pos_actual,elegida,0,cant_opciones);


          clrscr;


    until elegida=enter;

    menu_copado:=pos_actual;
end;


//--<
function menu(version:integer):integer;
begin
    if (version=1) or (version=0) then
    begin
            textcolor(4);writeln('MENU PRINCIPAL');
            writeln('---------------');textcolor(22);
            writeln();
            writeln('1) Provincias');
            writeln('2) Sintomas');
            writeln('3) Enfermedades');
            writeln('4) Pacientes');
            writeln('5) Historias Clinicas');
            writeln('6) Estadisticas');
            if version=0 then
            begin
                writeln('7) Borrar datos (D)');
                writeln('8) Mostrar datos (D)');
            end;
            writeln('0) Fin del Programa');textcolor(7);
            if version=0 then menu:=int_valido('Ingrese la opcion: ',0,8)
            else menu:=int_valido('Ingrese la opcion: ',0,6)
    end
    else if version=2 then menu:=menu_copado;

end;



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//PROGRAMA PRINCIPAL-------------------------------------------------hist--------------------------------------------------------------------------------------------
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


BEGIN
boot;

    limpiar_str3(cod_sint);
    limpiar_str3(cod_enf);
    limpiar_char(codprov);

    //Menu principal
    Andando:=True;
    while Andando = True do
        begin

            Case menu(2) of        //2 MENU COPADO - - - - 1 MENU COMUNACHO - - - - 0 MENU DEBUGGER
            1: Provincias;
            2: Sintomas;
            3: if (filesize(ASint)<>0) then Enfermedades else writeln('Todavia no fueron cargados los sintomas');
            4: if (filesize(AProv)>0)then Pacientes else writeln('Primero vas a tener que  cargar las provincias');
            5: if (filesize(Apac)>0)and(filesize(Aenf)>0)then historias else writeln('Tiene que haber datos cargados en Pacientes y en Enfermedades');
            6: Estadisticas;
            7: Borramela;
            8: mostrar_cosas;
            0: begin
               Andando:=False;
               shutdown;
               end;
            end;


            writeln;
            if(Andando) then
                begin
                    writeln('Press any key to continue...');readkey;
                    clrscr;
                end;
        end;

for q:= 1 to 5 do
begin
textcolor(q);writeln('Gracias por utilizar nuestro software :)');
delay(1);
end;
readkey;
END.
