% FONCTION DE REMPLISSAGE DES DICTIONNAIRES DE COINTEGRATION VECM ET CAUSALITE VAR
% INPUTS:
%   - aCorpNames   = Vecteur contenant le nom des entreprises
%   - aGlobalDico  = Dictionnaire global contenant les données associés à
%   chaques entreprises, quelque soit son modèle (coefficiants/t-stats/rangs/paramètres de significativité, etc.)
%   - aNbVAR       = Nombre d'entreprises suivant un modèle VAR dans le dictionnaire global
%   - aNbVECM      = Nombre d'entreprises suivant un modèle VECM dans le dictionnaire global
% OUTPUTS:
%   - DicoVECM     = Dictionnaire contenant les données assiciées aux entreprises suivant un modèle VECM
%   - DicoVAR      = Dictionnaire contenant les données assiciées aux entreprises suivant un modèle VAR

function [DicoVECM, DicoVAR] = FillDicos(aCorpNames, aGlobalDico, aNbVAR, aNbVECM)

DicoVECM = cell(aNbVECM+1,13);
DicoVECM(1,1) = {"Entreprise"};
DicoVECM(1,2) = {"Result Type"};
DicoVECM(1,3) = {"Rang <= 0"};
DicoVECM(1,4) = {"Rang <= 1"};
DicoVECM(1,5) = {"Restricted 0"};
DicoVECM(1,6) = {"Restricted c"};
DicoVECM(1,7) = {"Lambda 1"};
DicoVECM(1,8) = {"Signif Lambda1"};
DicoVECM(1,9) = {"Lambda 2"};
DicoVECM(1,10) = {"Signif Lambda2"};
DicoVECM(1,11) = {"HAS1"};
DicoVECM(1,12) = {"HAS2"};
DicoVECM(1,13) = {"GG"};

DicoVAR = cell(aNbVAR+1,10);
DicoVAR(1,1) = {"Entreprise"};
DicoVAR(1,2) = {"Result Type"};
DicoVAR(1,3) = {"H CDS->CS"};
DicoVAR(1,4) = {"Sum Coeff CDS->CS"};
DicoVAR(1,5) = {"Ftats CDS->CS"};
DicoVAR(1,6) = {"Pval CDS->CS"};
DicoVAR(1,7) = {"H CS->CDS"};
DicoVAR(1,8) = {"Sum Coeff CS->CDS"};
DicoVAR(1,9) = {"Ftats CS->CDS"};
DicoVAR(1,10) = {"Pval CS->CDS"};

currentRowCointegration = 2;
currentRowCausalite = 2;

for i = 1:(aNbVAR+aNbVECM)
ResultType = aGlobalDico(i,1);
ResultType = ResultType{1,1};
Result = aGlobalDico(i,2);
Result = Result{1,1};

    if ResultType(1:9) == 'Cointégra'
        DicoVECM{currentRowCointegration,1} = aCorpNames(1,i);
        DicoVECM(currentRowCointegration,2) = {ResultType};
        DicoVECM(currentRowCointegration,3) = {Result.Rank0TH};
        DicoVECM(currentRowCointegration,4) = {Result.Rank1TH};
        DicoVECM(currentRowCointegration,5) = {Result.Restricted0H};
        DicoVECM(currentRowCointegration,6) = {Result.RestrictedCH};
        DicoVECM(currentRowCointegration,7) = {Result.Lambda1};
        DicoVECM(currentRowCointegration,8) = {Result.Lambda1H};
        DicoVECM(currentRowCointegration,9) = {Result.Lambda2};
        DicoVECM(currentRowCointegration,10) = {Result.Lambda2H};
        DicoVECM(currentRowCointegration,11) = {Result.HAS1};
        DicoVECM(currentRowCointegration,12) = {Result.HAS2};
        DicoVECM(currentRowCointegration,13) = {Result.GG};
        currentRowCointegration = currentRowCointegration+1;
    elseif ResultType(1:9) == 'Causalité'
        DicoVAR{currentRowCausalite,1} = aCorpNames(1,i);
        DicoVAR(currentRowCausalite,2) = {ResultType};
        DicoVAR(currentRowCausalite,3) = {Result.H_CDSCauseCS};
        DicoVAR(currentRowCausalite,4) = {Result.SumCoeffCDSCauseCS};
        DicoVAR(currentRowCausalite,5) = {Result.FstatCDSCauseCS};
        DicoVAR(currentRowCausalite,6) = {Result.PvalCDSCauseCS};
        DicoVAR(currentRowCausalite,7) = {Result.H_CSCauseCDS};
        DicoVAR(currentRowCausalite,8) = {Result.SumCoeffCSCauseCDS};
        DicoVAR(currentRowCausalite,9) = {Result.FstatCSCauseCDS};
        DicoVAR(currentRowCausalite,10) = {Result.PvalCSCauseCDS};
        currentRowCausalite = currentRowCausalite+1;
    end
end


end

