# language: pt
Funcionalidade: RKZ-05 Detalhe do atendimento
  Como terapeuta da Rokuzen
  Quero ver os dados de um atendimento da minha agenda
  Para me preparar para a sessão

  Cenário: Tocar no atendimento abre o detalhe
    Dado que estou logado e hoje é {'2026-10-14'}
    E tenho os atendimentos
      | 'inicio'           | 'fim'              | 'paciente'    | 'unidade'                | 'tipo'       | 'situacao'  |
      | '2026-10-14 09:00' | '2026-10-14 10:30' | 'Mariana Souza' | 'West Plaza — São Paulo' | 'particular' | 'realizado' |
    Quando eu abro a agenda
    E eu toco em {'Mariana Souza'}
    Então eu vejo o detalhe do atendimento
      | 'campo'    | 'valor'                       |
      | 'Paciente' | 'Mariana Souza'               |
      | 'Data'     | 'quarta-feira, 14 de outubro' |
      | 'Horário'  | '09:00 – 10:30'               |
      | 'Duração'  | '1 h 30 min'                  |
      | 'Unidade'  | 'West Plaza — São Paulo'      |
      | 'Tipo'     | 'Particular'                  |
      | 'Situação' | 'Realizado'                   |
