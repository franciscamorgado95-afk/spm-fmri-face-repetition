%% comandos_figuras.m
% Demonstrador do SPM em fMRI (Metodos de Imagem Medica, NOVA FCT)
% Gera as figuras e as variacoes a partir da analise feita por
% face_rep_spm12_batch.m. Correr DEPOIS desse script.
%
% Colocar este ficheiro na mesma pasta que face_rep_spm12_batch.m.
% Correr seccao a seccao (Run Section) ou tudo de uma vez (Run).

%% 0. Caminhos
base = fileparts(mfilename('fullpath'));
p    = fullfile(base, 'face_rep', 'categorical');   % resultados do modelo
s    = fullfile(base, 'face_rep', 'Structural');    % imagem anatomica
out  = fullfile(base, 'Resultados');                % figuras
if ~exist(out, 'dir'), mkdir(out); end
anat = fullfile(s, 'wmsM03953_0007.nii');           % anatomica normalizada (MNI)

%% 1. Identificacao das regioes com o atlas Neuromorphometrics
xA = spm_atlas('load', 'Neuromorphometrics');
picos = [ 39 -70 -13;  45 -46 -19;  48 -79   5; -42 -58 -19;
         -42 -34 -19;  45  23  23; -27 -94   5;  33  20  -1;
         -54 -22  20;   3  11  50;  -3  11  50; -33  23  -1;
          30 -64  53; -39 -16  65; -60 -16  26;  51 -40   8]';
for i = 1:size(picos, 2)
    fprintf('%4d %4d %4d   %s\n', picos(:,i), spm_atlas('query', xA, picos(:,i)));
end

%% 2. Mapa limiarizado com correcao FWE (contraste 005: rostos > linha de base)
t_fwe = 4.82;   % limiar T para p<0.05 FWE, dado pelo SPM
spm_imcalc(fullfile(p, 'spmT_0005.nii'), fullfile(p, 'rostos_FWE.nii'), ...
           sprintf('i1.*(i1>%f)', t_fwe));

%% 3. Figuras sobre a anatomia (capturar a janela Graphics apos cada uma)
spm_check_registration(anat);
spm_orthviews('AddColouredImage', 1, fullfile(p, 'rostos_FWE.nii'), [1 0 0]);
spm_orthviews('Reposition', [45 -46 -19]);    % giro fusiforme direito
% -> guardar como Resultados/fusiforme_direito_FWE.png
% spm_orthviews('Reposition', [-39 -16 65]);  % giro pre-central esquerdo
% -> guardar como Resultados/motor_esquerdo_FWE.png

%% 4. Variacao 1: limiar sem correcao (p<0.001) vs. FWE (p<0.05)
T     = spm_read_vols(spm_vol(fullfile(p, 'spmT_0005.nii')));
t_unc = spm_invTcdf(1 - 0.001, 322);          % 322 graus de liberdade
fprintf('p<0.001 sem correcao: T > %.2f, %d voxels\n', t_unc, nnz(T > t_unc));
fprintf('p<0.05 FWE:           T > %.2f, %d voxels\n', t_fwe, nnz(T > t_fwe));
spm_imcalc(fullfile(p, 'spmT_0005.nii'), fullfile(p, 'rostos_unc001.nii'), ...
           sprintf('i1.*(i1>%f)', t_unc));
spm_check_registration(anat);
spm_orthviews('AddColouredImage', 1, fullfile(p, 'rostos_unc001.nii'), [1 1 0]);
spm_orthviews('AddColouredImage', 1, fullfile(p, 'rostos_FWE.nii'),    [1 0 0]);
spm_orthviews('Reposition', [45 -46 -19]);
% -> guardar como Resultados/variacao_limiar.png

%% 5. Variacao 2: resposta hemodinamica estimada no giro fusiforme direito
load(fullfile(p, 'SPM.mat'));
V   = spm_vol(fullfile(p, SPM.Vbeta(1).fname));
vox = round(V.mat \ [45 -46 -19 1]');         % mm (MNI) -> voxel
bf  = SPM.xBF.bf;                             % funcoes de base
t   = (0:size(bf,1)-1) * SPM.xBF.dt;
figure('Color', 'w'); hold on
cores  = {[0 0.45 0.74], [0 0.45 0.74], [0.85 0.33 0.1], [0.85 0.33 0.1]};
estilo = {'-', '--', '-', '--'};
for c = 1:numel(SPM.Sess(1).U)                % N1, N2, F1, F2
    cols = SPM.Sess(1).col(SPM.Sess(1).Fc(c).i);
    b = zeros(numel(cols), 1);
    for k = 1:numel(cols)
        Vb   = spm_vol(fullfile(p, SPM.Vbeta(cols(k)).fname));
        b(k) = spm_sample_vol(Vb, vox(1), vox(2), vox(3), 0);
    end
    plot(t, bf*b, 'LineWidth', 2, 'Color', cores{c}, 'LineStyle', estilo{c});
end
xlabel('Tempo apos o estimulo (s)'); ylabel('Resposta BOLD estimada (u.a.)');
title('Giro fusiforme direito (45, -46, -19)');
legend({'Nao famoso, 1.a', 'Nao famoso, 2.a', 'Famoso, 1.a', 'Famoso, 2.a'}, ...
       'Location', 'northeast');
grid on; xlim([0 25]);
try, theme(gcf, 'light'); end                 % fundo branco (MATLAB R2025a+)
exportgraphics(gcf, fullfile(out, 'hrf_fusiforme.png'), 'Resolution', 300);
