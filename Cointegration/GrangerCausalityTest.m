% FONCTION DE TEST DE CAUSALITE DE GRANGER
% INPUTS:
%   - aY        = S�rie expliqu�e et r�gress�e sur elle m�me
%   - aX        = S�rie causant potentiellement aY
%   - aLag      = Nombre de lag optimal pour les r�gressions
%   - aSeuil    = Seuil d'acceptation/rejet de l'hypoth�se nulle
% OUTPUTS:
%   - H            = Num�ro de l'hypoth�se accept�e
%   - SumCoeffNC   = Somme des coefficiants du mod�le non contraint (r�gress� sur LaggedY et LaggedX)
%   - FStat        = Statistique de test
%   - pval         = p-value du test

function [H, SumCoeffNC, FStat, critikVal, pval] = GrangerCausalityTest(aY, aX, aLag, aSeuil)

    % Cr�ation du lag
    laggedY = lagmatrix(aY,aLag);
    laggedX = lagmatrix(aX,aLag);
    laggedY = laggedY(aLag+1:end,1);
    laggedX = laggedX(aLag+1:end,1);
    Y = aY(aLag+1:end,1);
    
    % R�gression du Mod�le Contraint
    [~,~,residC] = regress(Y,laggedY);
    SCRC = sum(residC.^2);
  
	% R�gression du Mod�le Non Contraint
    [coeffNC,~,residNC] = regress(Y,[laggedY laggedX]);
    SumCoeffNC = sum(abs(coeffNC));
    SCRNC = sum(residNC.^2);
    
    % Test Fisher
    nObs = size(aY,1);
    FStat = ((SCRC-SCRNC)/2*aLag)/((SCRNC)/(nObs-2*aLag-1));
    critikVal = finv(aSeuil,2*aLag,nObs-2*aLag-1);
    pval = 1 - fcdf(FStat, 2*aLag,nObs-2*aLag-1);
    
    if FStat > critikVal && pval < aSeuil
        H = 1; % il existe au moins un coefficient non nul
    else
        H = 0; % il n'existe pas de coefficient non nul
    end
    
end

