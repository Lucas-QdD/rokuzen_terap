# language: pt
Funcionalidade: RKZ-01 Login do terapeuta
  Como terapeuta da Rokuzen
  Quero entrar no app com meu e-mail e senha
  Para consultar e gerenciar meus atendimentos

  Contexto:
    Dado que o app foi aberto sem sessão ativa

  Cenário: Credenciais válidas abrem a agenda
    Quando eu informo o e-mail {'terapeuta@rokuzen.com'}
    E eu informo a senha {'rokuzen123'}
    E eu toco em {'Entrar'}
    Então eu vejo a agenda

  Esquema do Cenário: Credenciais inválidas mostram erro e não dão acesso
    Quando eu informo o e-mail <email>
    E eu informo a senha <senha>
    E eu toco em {'Entrar'}
    Então eu vejo a mensagem {'E-mail ou senha incorretos.'}
    E eu continuo na tela de login

    Exemplos:
      | email                   | senha          |
      | 'terapeuta@rokuzen.com' | 'senha-errada' |
      | 'outra@rokuzen.com'     | 'rokuzen123'   |
