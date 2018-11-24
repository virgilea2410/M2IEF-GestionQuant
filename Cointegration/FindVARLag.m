% FONCTION DE RECHERCHE DE LAG OPTIMAL VIA AIC
% INPUTS:
%   - aSerie     = Vecteur contenant les série(s) testée(s) pour le lag optimal 
%   - aStartLag  = Nombre de lag minimum testé
%   - aEndLag    = Nombre de lag maximum testé
% OUTPUTS:
%   - LagOpt     = Lag optimal

function [LagOpt] = FindVARLag(aSerie, aStartLag, aEndLag)

AICVector = ones(aEndLag+1-aStartLag,1)*NaN;

% Estimation des modèle VARM et calcul du critère AIC
NbSeries = size(aSerie,2);
for i = aStartLag:aEndLag
    Lag = i;
    ModelVAR = varm(NbSeries,Lag);
    ResultVAR = estimate(ModelVAR,aSerie);
    Resuts = summarize(ResultVAR);
    AICVector(i-aStartLag+1,1) = Resuts.AIC;
end

% Minimisation du critère AIC
CritMin = min(AICVector, [], 1);
LagOpt = find(CritMin == AICVector)-1;

end

