% FONCTION DE RECHERCHE DE LAG OPTIMAL VIA AIC
% INPUTS:
%   - aSerie     = Vecteur contenant les s�rie(s) test�e(s) pour le lag optimal 
%   - aStartLag  = Nombre de lag minimum test�
%   - aEndLag    = Nombre de lag maximum test�
% OUTPUTS:
%   - LagOpt     = Lag optimal

function [LagOpt] = FindVARLag(aSerie, aStartLag, aEndLag)

AICVector = ones(aEndLag+1-aStartLag,1)*NaN;

% Estimation des mod�le VARM et calcul du crit�re AIC
NbSeries = size(aSerie,2);
for i = aStartLag:aEndLag
    Lag = i;
    ModelVAR = varm(NbSeries,Lag);
    ResultVAR = estimate(ModelVAR,aSerie);
    Resuts = summarize(ResultVAR);
    AICVector(i-aStartLag+1,1) = Resuts.AIC;
end

% Minimisation du crit�re AIC
CritMin = min(AICVector, [], 1);
LagOpt = find(CritMin == AICVector)-1;

end

