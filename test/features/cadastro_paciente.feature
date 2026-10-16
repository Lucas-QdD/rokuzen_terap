# language: pt
Funcionalidade: RKZ-06 Cadastro de paciente
  Como terapeuta da Rokuzen
  Quero cadastrar meus pacientes no app
  Para ter os contatos deles à mão

  Pela regra RN09, nome e telefone são obrigatórios; o telefone deve ter DDD,
  com 10 ou 11 dígitos, com ou sem máscara. E-mail, data de nascimento
  e observações são opcionais.

  Contexto:
    Dado que estou logado e hoje é {'2026-10-14'}
    E eu abro a agenda
    E eu abro o cadastro de paciente

  Cenário: Cadastro com todos os campos
    Quando eu preencho o nome {'Ana Beatriz Costa'}
    E eu preencho o telefone {'(11) 91234-5678'}
    E eu preencho o e-mail {'ana.costa@exemplo.com'}
    E eu preencho a data de nascimento {'12/04/1988'}
    E eu preencho as observações {'Prefere pressão leve.'}
    E eu toco em {'Salvar'}
    Então eu vejo o paciente {'Ana Beatriz Costa'} com telefone {'(11) 91234-5678'} na lista

  Esquema do Cenário: Telefone com ou sem máscara é aceito e formatado
    Quando eu preencho o nome {'Carlos Lima'}
    E eu preencho o telefone <digitado>
    E eu toco em {'Salvar'}
    Então eu vejo o paciente {'Carlos Lima'} com telefone <exibido> na lista

    Exemplos:
      | digitado          | exibido           |
      | '11987654321'     | '(11) 98765-4321' |
      | '11 98765 4321'   | '(11) 98765-4321' |
      | '(19) 3456-7890'  | '(19) 3456-7890'  |

  Esquema do Cenário: Campos inválidos impedem o cadastro
    Quando eu preencho o nome <nome>
    E eu preencho o telefone <telefone>
    E eu preencho o e-mail <email>
    E eu preencho a data de nascimento <nascimento>
    E eu toco em {'Salvar'}
    Então eu vejo a mensagem <mensagem>
    E eu continuo no cadastro de paciente

    Exemplos:
      | nome  | telefone           | email      | nascimento   | mensagem                                                     |
      | ''    | '(11) 91234-5678'  | ''         | ''           | 'Informe o nome.'                                            |
      | 'Ana' | ''                 | ''         | ''           | 'Informe o telefone.'                                        |
      | 'Ana' | '91234-5678'       | ''         | ''           | 'Telefone inválido: informe DDD e número (10 ou 11 dígitos).' |
      | 'Ana' | '(11) 91234-56789' | ''         | ''           | 'Telefone inválido: informe DDD e número (10 ou 11 dígitos).' |
      | 'Ana' | '(11) 91234-5678'  | 'ana@'     | ''           | 'E-mail inválido.'                                           |
      | 'Ana' | '(11) 91234-5678'  | ''         | '15/03/2030' | 'A data de nascimento não pode ser futura.'                  |
      | 'Ana' | '(11) 91234-5678'  | ''         | '31/02/1990' | 'Data inválida. Use dd/mm/aaaa.'                             |
