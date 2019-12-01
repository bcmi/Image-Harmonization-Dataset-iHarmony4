%
%   simple implementation of N-Dimensional PDF Transfer 
%
%   [DR] = pdf_transferND(D0, D1, rotations);
%
%     D0, D1 = NxM matrix containing N-dimensional fea               tures
%     rotations = { {R_1}, ... , {R_n} } with R_i PxN 
%
%     note that we can use more than N projection axes. In this case P > N
%     and the inverse transformation is done by least mean square. 
%     Using more than N axes leads to a more stable (but also slower) 
%     convergence.
%
%  (c) F. Pitie 2007
%
%  see reference:
%  Automated colour grading using colour distribution transfer. (2007) 
%  Computer Vision and Image Understanding.
%
function [DR] = pdf_transfer(D0, D1, Rotations, varargin)

nb_iterations = length(Rotations);

numvarargs = length(varargin);
if numvarargs > 1
    error('pdf_transfer:TooManyInputs', ...
        'requires at most 1 optional input');
end

optargs = {1};
optargs(1:numvarargs) = varargin;
[relaxation] = optargs{:};

prompt = '';

for it=1:nb_iterations
    fprintf(repmat('\b',[1, length(prompt)]))
    prompt = sprintf('IDT iteration %02d / %02d', it, nb_iterations);
    fprintf(prompt);
    
    R = Rotations{it};    
    nb_projs = size(R,1);
  
    % apply rotation
    
    D0R = R * D0;
    D1R = R * D1;
    D0R_ = zeros(size(D0));

    % get the marginals, match them, and apply transformation
    for i=1:nb_projs
        % get the data range
        datamin = min([D0R(i,:) D1R(i,:)])-eps;
        datamax = max([D0R(i,:) D1R(i,:)])+eps;
        u = (0:(300-1))/(300-1)*(datamax - datamin) + datamin;
        
        % get the projections
        p0R = hist(D0R(i,:), u);
        p1R = hist(D1R(i,:), u);

        % get the transport map
        f = pdf_transfer1D(p0R, p1R);
        
        % apply the mapping
        D0R_(i,:) = (interp1(u, f', D0R(i,:))-1)/(300-1)*(datamax-datamin) + datamin;
    end

    D0 = relaxation * (R \ (D0R_ - D0R)) + D0;
end

fprintf(repmat('\b',[1, length(prompt)]))


DR = D0;

end

%
% 1D - PDF Transfer
%
function f = pdf_transfer1D(pX,pY)
    nbins = max(size(pX));

    eps = 1e-6; % small damping term that faciliates the inversion
    
    PX = cumsum(pX + eps);
    PX = PX/PX(end);

    PY = cumsum(pY + eps);
    PY = PY/PY(end);

    % inversion

    f = interp1(PY, 0:nbins-1, PX, 'linear');
    f(PX<=PY(1)) = 0;
    f(PX>=PY(end)) = nbins-1;
    if sum(isnan(f))>0
        error('colour_transfer:pdf_transfer:NaN', ...
              'pdf_transfer has generated NaN values');
    end   
end

