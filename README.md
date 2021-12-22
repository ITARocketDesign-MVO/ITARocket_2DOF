# ITARocket_2---DOF

Simulador desenvolvido em Julia para substituir o simulador antigo (em MATLAB) da MVO.

Desenvolvido por:

* Pulga
* Hipster
* Barueri
* Chicão
* Coca
* Primo

### Documentação

#### Instalação e setup de Julia

Baixar Julia em https://julialang.org/downloads/. Por ora, não há requisito de versão, nem dependências.

O desenvolvimento é feito no VS Code. É necessário instalar a extensão _Julia_. Nas configurações dessa extensão, o campo _Julia: **Executable Path**_ deve conter o executável julia.exe. Geralmente, esse aplicativo fica no _AppData\Local\Programs_ do Windows. (adicionar local para Mac e Linux).

Aproveitando que estamos lidando com o executável, podemos adicioná-lo ao PATH do sistema para poder executar Julia do terminal. Em "Editar as variáveis de ambiente do sistema">"Variáveis de Ambiente...", edite a variável Path, adicionando o local do executável julia.exe à lista.

#### Inputs

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
