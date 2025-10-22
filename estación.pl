% rutas_guagua.pl
% Modelo de rutas de guagua, tiempos entre paradas y búsqueda de trayectos.

ruta(r1, [central, parque, hospital, universidad]).
ruta(r2, [central, mercado, estadio, playa]).
ruta(r3, [universidad, barrio_sur, mercado, aeropuerto]).

tiempo_entre(r1, central, parque, 8).
tiempo_entre(r1, parque, hospital, 6).
tiempo_entre(r1, hospital, universidad, 10).

tiempo_entre(r2, central, mercado, 7).
tiempo_entre(r2, mercado, estadio, 9).
tiempo_entre(r2, estadio, playa, 12).

tiempo_entre(r3, universidad, barrio_sur, 5).
tiempo_entre(r3, barrio_sur, mercado, 6).
tiempo_entre(r3, mercado, aeropuerto, 14).

ruta_consecutiva(R, A, B, T) :-
    tiempo_entre(R, A, B, T).
ruta_consecutiva(R, A, B, T) :-
    tiempo_entre(R, B, A, T).

vecino(Parada, Ruta, Siguiente, Tiempo) :-
    ruta(Ruta, Paradas),
    member(Parada, Paradas),
    ( append(_, [Parada, Siguiente | _], Paradas),
      tiempo_entre(Ruta, Parada, Siguiente, Tiempo)
    ; append(_, [Siguiente, Parada | _], Paradas),
      tiempo_entre(Ruta, Siguiente, Parada, Tiempo)
    ).

sum_list([], 0).
sum_list([H|T], Sum) :-
    sum_list(T, Rest),
    Sum is H + Rest.

dfs(Actual, Destino, Visitadas, CaminoRev, RutasAcc, TiempoAcc, Camino, RutasUsadas, TiempoTotal) :-
    Actual = Destino,
    reverse([Actual|CaminoRev], CaminoRevR),
    Camino = CaminoRevR,
    reverse(RutasAcc, RutasUsadas),
    TiempoTotal = TiempoAcc.

dfs(Actual, Destino, Visitadas, CaminoRev, RutasAcc, TiempoAcc, Camino, RutasUsadas, TiempoTotal) :-
    vecino(Actual, Ruta, Siguiente, TiempoPaso),
    \+ member(Siguiente, Visitadas),
    (   RutasAcc = [RutaPrev | _] ->
        ( RutaPrev = Ruta -> NewRutasAcc = RutasAcc ; NewRutasAcc = [Ruta|RutasAcc] )
    ;   NewRutasAcc = [Ruta]
    ),
    NewTiempoAcc is TiempoAcc + TiempoPaso,
    dfs(Siguiente, Destino, [Siguiente|Visitadas], [Actual|CaminoRev], NewRutasAcc, NewTiempoAcc, Camino, RutasUsadas, TiempoTotal).

trayectos(Inicio, Fin, Resultados) :-
    setof(tray(Camino, Rutas, Tiempo, Transbordos),
          ( dfs(Inicio, Fin, [Inicio], [], [], 0, Camino, Rutas, Tiempo),
            length(Rutas, LR), Transbordos is LR - 1
          ), Resultados), !.
trayectos(_, _, []) :- fail.

mejor_por_tiempo(Inicio, Fin, Mejor) :-
    trayectos(Inicio, Fin, R),
    predsort(cmp_tiempo, R, Ordenados),
    Ordenados = [Mejor|_].

cmp_tiempo(Delta, tray(_,_,T1,_), tray(_,_,T2,_)) :-
    ( T1 < T2 -> Delta = '<' ; T1 > T2 -> Delta = '>' ; Delta = '=' ).

mejor_por_transbordo(Inicio, Fin, Mejor) :-
    trayectos(Inicio, Fin, R),
    predsort(cmp_transbordo_tiempo, R, Ordenados),
    Ordenados = [Mejor|_].

cmp_transbordo_tiempo(Delta, tray(_,_,T1,Tr1), tray(_,_,T2,Tr2)) :-
    ( Tr1 < Tr2 -> Delta = '<'
    ; Tr1 > Tr2 -> Delta = '>'
    ; ( T1 < T2 -> Delta = '<' ; T1 > T2 -> Delta = '>' ; Delta = '=' )
    ).

mostrar_trayecto(tray(Camino, Rutas, Tiempo, Transbordos)) :-
    format('Camino: ~w~n', [Camino]),
    format('Rutas usadas: ~w~n', [Rutas]),
    format('Tiempo total (min): ~w~n', [Tiempo]),
    format('Transbordos: ~w~n', [Transbordos]).
