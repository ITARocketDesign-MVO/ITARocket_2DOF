# Documentação

Referência sobre o 2DOF para consulta durante o desenvolvimento e uso.

## Configuração

### Instalação e setup de Julia

Baixar Julia em https://julialang.org/downloads/. Por ora, não há requisito de versão, nem dependências.

O desenvolvimento é feito no VS Code. É necessário instalar a extensão _Julia_. Nas configurações dessa extensão, o campo _Julia: **Executable Path**_ deve conter o executável julia.exe. Geralmente, esse aplicativo fica no _AppData\Local\Programs_ do Windows. (adicionar local para Mac e Linux).

Aproveitando que estamos lidando com o executável, podemos adicioná-lo ao PATH do sistema para poder executar Julia do terminal. Em "Editar as variáveis de ambiente do sistema">"Variáveis de Ambiente...", edite a variável Path, adicionando o local do executável julia.exe à lista.

### Ambientes e packages

O que fazer quando precisamos usar código escrito por outras pessoas, como por exemplo para fazer gráficos, ou usar o nosso próprio código (ao invés de desenvolvê-lo)?

A resposta é usar ambientes e packages. Packages são conjuntos de código que podem ser instalados para uso. No terminal do Julia, digite `]` e você verá o terminal de packages aparecer. Algo como `(@v1.6) pkg>` aparece antes do seu cursor. Entre parênteses está o _ambiente_ atual. Nesse caso, estamos no ambiente global (pois a versão do Julia é exibida). Packages instaladas nesse ambiente poderão ser usadas de qualquer diretório do seu computador (exceto de outros ambientes. Calma. Vamos chegar lá).

Para instalar uma package, usamos `add NomeDaPackage`. Comandos úteis:
* `status`: exibe as packages instaladas
* `rm [PKG]`: remove PKG ou todas as packages se o argumento for omitido
* `update [PKG]`: atualiza PKG ou tudo se PKG omitido.

Instalar packages no ambiente global é conveniente, mas tem alguns problemas. Pode haver algum conflito de versão necessária de packages usadas em mais de um projeto, por exemplo. Mas imagine a seguinte situação: você está desenvolvendo um projeto, que outras pessoas precisam reproduzir em máquinas que não são suas. Você depende de packages externas, instala no seu ambiente global e seu código funciona! Bizu? Na verdade, bizuleu insano. Não há garantia de que seus usuários terão as mesmas packages instaladas no computador deles.

Para resolver isso, você deve instalar as packages necessárias num ambiente _dedicado_ ao seu projeto. Para criar um ambiente, abra um terminal de Julia na pasta que você está usando para o seu projeto, e vá para o terminal de packages. Com o comando `activate .`, você pode ver que o conteúdo dos parênteses no prompt mudou para o nome da sua pasta atual. Você acabou de criar um ambiente naquela pasta. Agora, instale, remova, atualize packages à vontade nesse ambiente. Todas as alterações feitas nas packages instaladas serão registradas em dois arquivos (que fazem parte do seu projeto!): `Project.toml` e `Manifest.toml`.

O arquivo `Project.toml` contém um resumo das suas dependências diretas. O arquivo `Manifest.toml` contém uma lista exaustiva (gerada automaticamente) de todas as dependências diretas e indiretas do seu projeto. Se você compartilhar esses arquivos com outras pessoas, elas poderão clonar o seu ambiente. Em um ambiente recém-ativado com um `Project.toml` e um `Manifest.toml`, o comando `instantiate .` instalará todas as dependências especificadas.

Você perceberá que o `Project.toml` do 2DOF contém alguns campos que não existem ao gerar esse arquivo apenas instalando packages em um ambiente. Os campos incluem um nome, autores, a versão e um UUID. Isso ocorre porque o 2DOF é uma package, não apenas um ambiente. Esse ambiente segue uma estrutura específica, necessária para a instalação do código em outras máquinas. (Para criar packages, existe o comando `generate`, mas isso não deve ser feito de novo!). Com o ambiente ITARocket_2DOF ativado, podemos escrever `using ITARocket_2DOF` como qualquer outra package!

Por fim, precisamos usar a package do 2DOF de outros ambientes. Afinal, não devemos misturar informações de um projeto específico (uma simulação específica) com a infraestrutura do código. Para fazer isso, temos algumas alternativas: usar os comandos `add` ou `dev`, nos modos local ou remoto. São 4 opções e sugou explicar todas. Vamos ver apenas os modos add remoto e dev local.

Como a nossa package não é registrada (ainda!), podemos dar o comando `add link.do.repositorio`. Isso vai tentar instalar o conteúdo do repositório como package no ambiente atual. Ao usar o comando `status`, você pode verificar a versão da package especificada no `Project.toml`. Por padrão, o último commit da main é usado, mas você pode adicionar commita antigos ou branches adicionando um `#` com o hash do commit ou o nome da branch depois do link do repositório. Ao fazer novos commits, lembre-se de dar um `update` no seu ambiente! Depois disso, você pode usar a package como qualquer outra. A package pode ser removida com `rm`.

A segunda opção é usar o comando `dev`. Esse comando instrui o gerenciador de packages a carregar o código com quaisquer mudanças locais que você fez nele. Ao inserir `dev diretorioDaPackage` no terminal de packages, você estará carregando o código mais recente desse diretório. Por isso, esse comando é usado para testar código em desenvolvimento. Você pode usar esse comando com o diretório onde clonou o repositório, fazer mudanças locais nos arquivos e estas serão carregadas na próxima vez que você usar a package no seu código, sem a necessidade de um update. Esse comando não exige que a package seja um repositório do github.


Mais informações [aqui](https://pkgdocs.julialang.org/v1/managing-packages/).

### Inputs

Os inputs podem ser colocados de forma manual ou através de leitura de arquivo. No modo manual, todos os parâmetros são `keyword arguments` e estão no SI. Para o input por arquivo, valem as seguintes regras:

* O arquivo deve se chamar `Entradas.txt` e estar em uma pasta dedicada ao projeto.
* As linhas desse arquivo que serão interpretadas devem ter a forma `CHAVE : VALOR`, onde `CHAVE` é texto e `VALOR` é texto ou um valor numérico. Apenas linhas com ' (e apenas 1) `:`serão interpretadas.
* * Várias chaves podem se corresponder com um mesmo parâmetro de entrada. Quando um parâmetro de entrada tiver mais de uma chave correspondente, apenas uma delas deve ser usada no arquivo de entrada, pois são alternativas.
* Massa vazia
  * Massa vazia (kg): float
* Coeficiente de arrasto
  * Cd do foguete: float
  * Tabela de Cd do foguete: string (nome do arquivo ou `tabela` para nome padrão)
* Area transversal
  * Area transversal do foguete (m^2): float
  * Diametro do foguete (m): float
  * Raio do foguete (m): float
* Empuxo
  * Empuxo (N): float
  * Tabela de Empuxo: (nome do arquivo ou `tabela` para nome padrão)
* Massa de propelente
  * Massa de propelente (kg): float
* Tempo de queima
  * Tempo de queima (s): float
* Cd do drogue
  * Cd do drogue: float
* Area do drogue
  * Area do drogue (m^2): float
* Cd do main
  * Cd do main: float
* Area do main
  * Area do main (m^2): float
* ângulo de lançamento
  * Angulo de lancamento (graus): float
* Altitude de lancamento
  * Altitude de lancamento (m): float
* Comprimento do trilho
  * Comprimento do trilho (m): float
  * Comprimento do trilho (ft): float