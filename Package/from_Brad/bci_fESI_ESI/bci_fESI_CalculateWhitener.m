function W=bci_fESI_CalculateWhitener(NoiseCov,rnkC_noise,isPca)

    [V,D] = eig(NoiseCov);
%     V=real(V); D=real(D);
    % In some case, eig returns complex values
    if ~isreal(D)
        error('Complex values in the eigvalues...');
    end
    D = diag(D); 
    [D,I] = sort(D,'descend');
    V = V(:,I);
    % No PCA case.
    if ~isPca
%         display(['wMNE> Not doing PCA for ' Modality '.'])
        D = 1 ./ D; %figure; plot(D)
        W = diag(sqrt(D)) * V;
    % Rey's approach. MNE has been changed to implement this.
    else
%         display(['wMNE> Setting small ' Modality ' eigenvalues to zero.'])
        D = 1 ./ D; 
        D(rnkC_noise+1:end) = 0; %figure; plot(D)
        W = diag(sqrt(D)) * V';
        W = W(1:rnkC_noise,:); % This line will reduce the actual number of variables in data and leadfield to the true rank. This was not done in the original MNE C code.
    end
end