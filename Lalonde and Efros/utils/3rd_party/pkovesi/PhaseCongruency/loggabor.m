% LOGGABOR
%
% Plots 1D log-Gabor functions
%

% Author: Peter Kovesi   
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk @ csse uwa edu au    http://www.csse.uwa.edu.au/~pk   


function loggabor(nscale, wmin, mult, konwo)
    
    Npts = 2048;
    Nwaves = 1;
    
    wmax = 0.5;
    dw =   wmax/(Npts-1);
    w = [0: dw: wmax]; 
    
    wo = wmin/2;
    for s = 1:nscale
	w(1) = 1;                   % fudge
	Gw{s} = exp( (-(log(w/wo)).^2) ./ (2*(log(konwo)).^2) );
	Gw{s}(1) = 0;               % undo fudge
	
	

	Wave{s} = fftshift(ifft(Gw{s}));
	wavelength = 1/wo;
	p = max(round(Npts/2 - Nwaves*wavelength),1);
	q = min(round(Npts/2 + Nwaves*wavelength),Npts);
	Wave{s} = Wave{s}(p:q);
	
	wo = wo*mult;
    end
    
    w(1) = 0; % undo fudge    
    
    lw = 2;  % linewidth
    fs = 14; % font size
    figure(1), clf
    for s = 1:nscale
	subplot(2,1,1), plot(w, Gw{s},'LineWidth',lw), 
	axis([0 0.5 0 1.1]), hold on
	subplot(2,1,2), semilogx(w, Gw{s},'LineWidth',lw), axis([0 0.5 0 1.1]), hold on
    end
    
    subplot(2,1,1), title('Log-Gabor Transfer Functions','FontSize',fs);
    xlabel('frequency','FontSize',fs)
    subplot(2,1,2), xlabel('log frequency','FontSize',fs)

    ymax = 1.05*max(abs(Wave{nscale}));

    figure(2), clf
    for s = 1:nscale    
	subplot(2,nscale,s), plot(real(Wave{s}),'LineWidth',lw), 
        axis([0 length(Wave{s}) -ymax ymax]), axis off
	subplot(2,nscale,s+nscale), plot(imag(Wave{s}),'LineWidth',lw),
	axis([0 length(Wave{s}) -ymax ymax]), axis off
    end
    
subplot(2,nscale,1), title('even symmetric wavelets','FontSize',fs);
subplot(2,nscale,nscale+1), title('odd symmetric wavelets','FontSize',fs);