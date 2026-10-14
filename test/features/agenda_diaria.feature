# language: pt
Funcionalidade: RKZ-03 Agenda do dia
  Como terapeuta da Rokuzen
  Quero ver os atendimentos de cada dia em ordem de horário
  Para saber quem vou atender, em qual unidade e a situação de cada atendimento

  Contexto:
    Dado que estou logado e hoje é {'2026-10-14'}
    E tenho os atendimentos
      | 'inicio'           | 'fim'              | 'paciente'          | 'unidade'                   | 'tipo'       | 'situacao'  |
      | '2026-10-14 14:30' | '2026-10-14 15:30' | 'Carlos Lima'       | 'Grand Plaza — Santo André' | 'clinica'    | 'agendado'  |
      | '2026-10-14 09:00' | '2026-10-14 10:30' | 'Mariana Souza'     | 'West Plaza — São Paulo'    | 'particular' | 'realizado' |
      | '2026-10-14 11:00' | '2026-10-14 12:00' | 'Fernanda Oliveira' | 'Mooca Plaza — São Paulo'   | 'clinica'    | 'cancelado' |
      | '2026-10-15 10:00' | '2026-10-15 11:00' | 'Roberto Takahashi' | 'Mooca Plaza — São Paulo'   | 'clinica'    | 'agendado'  |
      | '2026-10-13 16:00' | '2026-10-13 17:00' | 'Juliana Pereira'   | 'West Plaza — São Paulo'    | 'clinica'    | 'falta'     |

  Cenário: Atendimentos do dia aparecem em ordem de horário
    Quando eu abro a agenda
    Então eu vejo o dia {'quarta-feira, 14 de outubro'}
    E eu vejo os atendimentos nesta ordem
      | 'horario' | 'paciente'          | 'unidade'                   | 'situacao'  |
      | '09:00'   | 'Mariana Souza'     | 'West Plaza — São Paulo'    | 'Realizado' |
      | '11:00'   | 'Fernanda Oliveira' | 'Mooca Plaza — São Paulo'   | 'Cancelado' |
      | '14:30'   | 'Carlos Lima'       | 'Grand Plaza — Santo André' | 'Agendado'  |

  Cenário: Navegar para o próximo dia
    Quando eu abro a agenda
    E eu vou para o próximo dia
    Então eu vejo o dia {'quinta-feira, 15 de outubro'}
    E eu vejo os atendimentos nesta ordem
      | 'horario' | 'paciente'          | 'unidade'                 | 'situacao' |
      | '10:00'   | 'Roberto Takahashi' | 'Mooca Plaza — São Paulo' | 'Agendado' |

  Cenário: Navegar para o dia anterior
    Quando eu abro a agenda
    E eu volto para o dia anterior
    Então eu vejo o dia {'terça-feira, 13 de outubro'}
    E eu vejo os atendimentos nesta ordem
      | 'horario' | 'paciente'        | 'unidade'                | 'situacao' |
      | '16:00'   | 'Juliana Pereira' | 'West Plaza — São Paulo' | 'Falta'    |

  Cenário: Dia sem atendimentos mostra aviso
    Quando eu abro a agenda
    E eu vou para o próximo dia
    E eu vou para o próximo dia
    Então eu vejo o dia {'sexta-feira, 16 de outubro'}
    E eu vejo a mensagem {'Nenhum atendimento neste dia.'}
    E eu não vejo nenhum atendimento
