# language: pt
Funcionalidade: RKZ-04 Agenda semanal
  Como terapeuta da Rokuzen
  Quero ver quantos atendimentos tenho em cada dia da semana
  Para planejar a semana e abrir rapidamente a agenda de um dia

  Contexto:
    Dado que estou logado e hoje é {'2026-10-14'}
    E tenho os atendimentos
      | 'inicio'           | 'fim'              | 'paciente'          | 'unidade'                   | 'tipo'       | 'situacao'  |
      | '2026-10-14 09:00' | '2026-10-14 10:30' | 'Mariana Souza'     | 'West Plaza — São Paulo'    | 'particular' | 'agendado'  |
      | '2026-10-14 14:30' | '2026-10-14 15:30' | 'Carlos Lima'       | 'Grand Plaza — Santo André' | 'clinica'    | 'agendado'  |
      | '2026-10-15 10:00' | '2026-10-15 11:00' | 'Roberto Takahashi' | 'Mooca Plaza — São Paulo'   | 'clinica'    | 'agendado'  |
      | '2026-10-17 09:00' | '2026-10-17 10:00' | 'Fernanda Oliveira' | 'Mooca Plaza — São Paulo'   | 'clinica'    | 'agendado'  |
      | '2026-10-17 11:00' | '2026-10-17 12:00' | 'Juliana Pereira'   | 'Mooca Plaza — São Paulo'   | 'clinica'    | 'cancelado' |
      | '2026-10-17 13:00' | '2026-10-17 14:00' | 'Paulo Nakamura'    | 'Mooca Plaza — São Paulo'   | 'particular' | 'agendado'  |
      | '2026-10-20 16:00' | '2026-10-20 17:00' | 'Mariana Souza'     | 'West Plaza — São Paulo'    | 'clinica'    | 'agendado'  |

  Cenário: Quantidade de atendimentos em cada dia da semana
    Quando eu abro a agenda
    E eu toco em {'Semana'}
    Então eu vejo a semana {'11 a 17 de outubro'}
    E eu vejo a quantidade de atendimentos por dia
      | 'dia'                          | 'quantidade'         |
      | 'domingo, 11 de outubro'       | 'Nenhum atendimento' |
      | 'segunda-feira, 12 de outubro' | 'Nenhum atendimento' |
      | 'terça-feira, 13 de outubro'   | 'Nenhum atendimento' |
      | 'quarta-feira, 14 de outubro'  | '2 atendimentos'     |
      | 'quinta-feira, 15 de outubro'  | '1 atendimento'      |
      | 'sexta-feira, 16 de outubro'   | 'Nenhum atendimento' |
      | 'sábado, 17 de outubro'        | '3 atendimentos'     |

  Cenário: Tocar no dia abre a agenda diária daquele dia
    Quando eu abro a agenda
    E eu toco em {'Semana'}
    E eu toco em {'quinta-feira, 15 de outubro'}
    Então eu vejo o dia {'quinta-feira, 15 de outubro'}
    E eu vejo os atendimentos nesta ordem
      | 'horario' | 'paciente'          | 'unidade'                 | 'situacao' |
      | '10:00'   | 'Roberto Takahashi' | 'Mooca Plaza — São Paulo' | 'Agendado' |

  Cenário: Navegar para a próxima semana
    Quando eu abro a agenda
    E eu toco em {'Semana'}
    E eu vou para a próxima semana
    Então eu vejo a semana {'18 a 24 de outubro'}
    E eu vejo a quantidade de atendimentos por dia
      | 'dia'                        | 'quantidade'         |
      | 'domingo, 18 de outubro'     | 'Nenhum atendimento' |
      | 'terça-feira, 20 de outubro' | '1 atendimento'      |

  Cenário: Voltar da visão semanal para a diária
    Quando eu abro a agenda
    E eu toco em {'Semana'}
    E eu toco em {'Dia'}
    Então eu vejo o dia {'quarta-feira, 14 de outubro'}
    E eu vejo os atendimentos nesta ordem
      | 'horario' | 'paciente'      | 'unidade'                   | 'situacao' |
      | '09:00'   | 'Mariana Souza' | 'West Plaza — São Paulo'    | 'Agendado' |
      | '14:30'   | 'Carlos Lima'   | 'Grand Plaza — Santo André' | 'Agendado' |
