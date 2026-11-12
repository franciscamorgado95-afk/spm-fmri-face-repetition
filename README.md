# Demonstrador do SPM na análise de fMRI: repetição de rostos

Trabalho prático B da unidade curricular **Métodos de Imagem Médica** (NOVA FCT, 2026/27).

Este repositório reproduz a análise de um estudo de fMRI com o software
[SPM](https://www.fil.ion.ucl.ac.uk/spm/) (Statistical Parametric Mapping), desde as
imagens brutas até aos mapas de ativação cerebral, e inclui duas variações à análise:
o efeito do limiar estatístico e a resposta hemodinâmica estimada no giro fusiforme.

**Autores:** Francisca Morgado, Carolina Reis

## Requisitos

- MATLAB (testado na versão R2026b)
- SPM26 (versão 26.10.01), disponível no [GitHub do SPM](https://github.com/spm/spm/releases)
- Cerca de 1 GB de espaço livre

## Dados

Os dados **não estão incluídos** neste repositório. São o dataset de demonstração
"Repetition priming" (rostos famosos e não famosos) do SPM, destinado a fins de ensino,
e podem ser descarregados na página oficial:

https://www.fil.ion.ucl.ac.uk/spm/data/face_rep/

O paradigma experimental está descrito em Henson et al. (2002), *Cerebral Cortex*, 12, 178–186.

## Como reproduzir a análise

1. Instalar o SPM e adicioná-lo ao caminho do MATLAB:
   ```matlab
   addpath /caminho/para/spm
   savepath
   ```
2. Criar uma pasta de trabalho e colocar lá:
   - a pasta `face_rep` (dados descomprimidos);
   - os ficheiros `face_rep_spm12_batch.m` e `comandos_figuras.m` deste repositório.
3. No MATLAB, ir para essa pasta e correr a análise completa (demora 10 a 20 minutos):
   ```matlab
   spm fmri
   face_rep_spm12_batch
   ```
4. Gerar as figuras e as variações:
   ```matlab
   comandos_figuras
   ```

## Conteúdo

| Ficheiro | Descrição |
|---|---|
| `face_rep_spm12_batch.m` | *Script* oficial do SPM para este dataset: pré-processamento, modelo e contrastes. Foram desativadas as linhas 16–18, que descarregavam os dados de novo. |
| `comandos_figuras.m` | Identificação das regiões com o atlas, figuras sobre a anatomia, comparação de limiares e curvas da resposta hemodinâmica. |
| `Resultados/` | Figuras obtidas. |

## Pipeline

Correção temporal dos cortes → realinhamento → corregisto → segmentação → normalização
para o espaço MNI → suavização → especificação do modelo (4 condições × 3 funções de base)
→ estimação → contrastes.

## Referências

- Tierney, T. M. et al. (2025). SPM 25: open source neuroimaging analysis software.
  *Journal of Open Source Software*, 10(110), 8103. https://doi.org/10.21105/joss.08103
- Henson, R. N. A. et al. (2002). Face repetition effects in implicit and explicit memory
  tests as measured by fMRI. *Cerebral Cortex*, 12(2), 178–186.
