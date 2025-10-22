% Base de conocimientos: enfermedades y sus sintomas con pesos (probabilidad relativa)
sintoma_probable(gripe, fiebre, 0.8).
sintoma_probable(gripe, tos, 0.7).
sintoma_probable(gripe, dolor_cabeza, 0.6).

sintoma_probable(dengue, fiebre, 0.9).
sintoma_probable(dengue, dolor_muscular, 0.8).
sintoma_probable(dengue, erupcion_cutanea, 0.7).

sintoma_probable(covid, fiebre, 0.85).
sintoma_probable(covid, tos, 0.75).
sintoma_probable(covid, perdida_olfato, 0.9).

% Recomendaciones asociadas a cada enfermedad
recomendacion(gripe, 'Reposo, líquidos y paracetamol. Consultar si persiste.').
recomendacion(dengue, 'Acudir al médico. No tomar aspirina. Hidratación urgente.').
recomendacion(covid, 'Aislamiento, uso de mascarilla y prueba PCR si es posible.').

% Regla: obtiene lista de pesos para los sintomas dados y enfermedad
pesos_para_enfermedad(Enf, Sintomas, Pesos) :-
    findall(Peso, (
        member(S, Sintomas),
        sintoma_probable(Enf, S, Peso)
    ), Pesos).

% Regla: suma una lista de números (compatibilidad con versiones que no tienen sum_list)
sum_list([], 0).
sum_list([H|T], Sum) :-
    sum_list(T, Rest),
    Sum is H + Rest.

% Regla: calcula puntaje total para una enfermedad dada una lista de sintomas
puntaje(Enfermedad, Sintomas, Puntaje) :-
    pesos_para_enfermedad(Enfermedad, Sintomas, Pesos),
    sum_list(Pesos, Puntaje).

% Regla: diagnostico con umbral mínimo de coincidencia (ajustable)
diagnostico(Sintomas, Enfermedad, Puntaje, Recomendacion) :-
    puntaje(Enfermedad, Sintomas, Puntaje),
    Puntaje >= 1.5,
    recomendacion(Enfermedad, Recomendacion).

% Regla auxiliar: diagnosticos ordenados por puntaje (descendente)
diagnosticos_ordenados(Sintomas, ListaEnfPuntReco) :-
    findall(p(Enf, Punt, Reco), diagnostico(Sintomas, Enf, Punt, Reco), L),
    sort(2, @>=, L, ListaEnfPuntReco). % ordenar por Puntaje descendente
