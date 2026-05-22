function save_pub_pdf_one(x_vec, y_vec1, y_vec2, y_vec3, y_vec4, fname, span, xname, yname)
% SAVE_PUB_PDF  Create a tight, LaTeX-ready PDF from (x,y) without exportgraphics.
% span = 'one' (8.6 cm) or 'two' (17.8 cm).  fname like 'my_figure.pdf'

%     if nargin < 3 || isempty(fname), fname = 'my_figure.pdf'; end
%     if nargin < 4, span = 'one'; end
    switch lower(span)
        case 'one', width_cm = 8;  % typical one-column
        case 'two', width_cm = 17.8; % typical two-column
        otherwise,  width_cm = 8.6;
    end
    height_cm = 0.7*width_cm;        % pleasant aspect; tweak if needed

    % --- Figure & axes ---
    f = figure('Units','centimeters','Position',[2 2 width_cm height_cm], ...
               'Color','w','InvertHardcopy','off','Renderer','painters');
    ax = axes('Parent',f);

    plot(ax, x_vec, y_vec1, 'o','LineWidth',1.5,'MarkerSize',8,'Color',[0 0 0]);
    grid(ax,'on'); box(ax,'on'); hold on;
    plot(x_vec, y_vec2, '-', 'LineWidth', 1.5, 'MarkerSize', 6, 'Color', [1 0 0]); 
    plot(x_vec, y_vec3, 'x','LineWidth',1.0,'MarkerSize',8,'Color',[0 0 0]);
    plot(x_vec, y_vec4, '*','LineWidth',1.0,'MarkerSize',8,'Color',[0 0 0]);
    %legend('average', '(0.993)^n', '$3 \mu s$ hold', '$8 \mu s$ hold','Interpreter', 'latex');
%     legend({'average','(0.993)^n','3 \mu s hold','8 \mu s hold'}, ...
%        'Interpreter','latex', ...
%        'Location','southwest');
%    legend({'average','(0.993)^n','$3\,\mu s$ hold','$8\,\mu s$ hold'}, ...
%        'Interpreter','latex', ...
%        'Location','southwest');
   lgd = legend({'average','(0.993)^n','$3\,\mu s$ hold','$8\,\mu s$ hold'}, ...
       'Interpreter','latex');    
   lgd.Position = [0.2 0.25 0.2 0.15];
   lgd.Box = 'off';
    
    xname1 = [xname];
    yname1 = [yname];
    xlim([-0.2 20.2])
    % Labels with LaTeX interpreter
    xlabel(xname1, 'Interpreter', 'latex');
    ylabel(yname1, 'Interpreter', 'latex');

    ax.FontName = 'Times New Roman'; % matches many journals; or 'Times'
    ax.FontSize = 9.5;               % good for two-column tick labels
    ax.LineWidth = 0.75;

    %axis(ax,'tight');
    % Shrink outer margins to near-tight (avoid clipping)
    set(ax,'LooseInset', max(get(ax,'TightInset'), 0.02));

    % --- Critical: paper setup makes a tight PDF with no extra margins ---
    set(f, 'PaperUnits','centimeters');
    set(f, 'PaperPosition', [0 0 width_cm height_cm]);  % fill the page
    set(f, 'PaperSize',     [width_cm height_cm]);      % match figure size
    set(f, 'PaperPositionMode','manual');

    % --- Vector PDF export (older MATLAB-friendly) ---
    if ~endsWith(fname, '.pdf', 'IgnoreCase', true), fname = [fname '.pdf']; end
    print(f, fname, '-dpdf', '-painters', '-r300'); % vector + decent embedded images

    fprintf('Wrote %s (%.2f x %.2f cm)\n', fname, width_cm, height_cm);
end