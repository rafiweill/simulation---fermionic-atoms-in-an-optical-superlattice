function save_pub_pdf(x1, y1,x1a, y1a, x2, y2, x2a,y2a, fname, span, titles, xlabels, ylabel_str)

    if nargin < 5 || isempty(fname), fname = 'my_two_panel.pdf'; end
    if nargin < 6 || isempty(span),  span  = 'one'; end
    if nargin < 7 || isempty(titles),     titles     = {'',''}; end
    if nargin < 8 || isempty(xlabels),    xlabels    = {'',''}; end
    if nargin < 9 || isempty(ylabel_str), ylabel_str = ''; end

    switch lower(span)
        case 'one', width_cm = 8.6;   % typical one-column width
        case 'two', width_cm = 17.8;  % full two-column width
        otherwise,  width_cm = 8.6;
    end
    height_cm = 0.42 * width_cm;      % pleasant aspect for two panels

    % Figure
    f = figure('Units','centimeters','Position',[2 2 width_cm height_cm], ...
               'Color','w','InvertHardcopy','off','Renderer','painters');

    % --- Create two subplots and make spacing compact (manual positions) ---
    % Normalized layout params (tweak if needed)
    lmargin = 0.08;  % left outer margin
    rmargin = 0.05;  % right outer margin
    bmargin = 0.28;  % bottom margin (for x labels)
    tmargin = 0.12;  % top margin (for titles)
    hgap    = 0.06;  % gap between the two panels

    axW = (1 - lmargin - rmargin - hgap)/2;
    axH = 1 - bmargin - tmargin;

    ax1 = subplot(1,2,1,'Parent',f);
    set(ax1,'Units','normalized','Position',[lmargin bmargin axW axH]);
    plot(ax1, x1, y1, '-','LineWidth',1.2,'Color', [0 0.4470 0.7410]); hold on; 
    plot(ax1, x1a, y1a, 'o','MarkerSize',4, 'Color', [0 0.4470 0.7410]); 
    ylim(ax1,[-0.02, 1.02])
    grid(ax1,'on'); box(ax1,'on');
    xlabel(ax1, xlabels{1}, 'Interpreter','latex');
    ylabel(ax1, ylabel_str, 'Interpreter','latex');
    title(ax1, titles{1}, 'Interpreter','latex');

    ax2 = subplot(1,2,2,'Parent',f);
    set(ax2,'Units','normalized','Position',[lmargin+axW+hgap bmargin axW axH]);
    plot(ax2, x2, y2,'LineWidth',1.2,'Color', [0.85 0.33 0.10]); hold on;
    plot(ax2, x2a, y2a, 'o','MarkerSize',4, 'Color', [0.85 0.33 0.10]); 
    ylim(ax2,[-0.02, 1.02])
    grid(ax2,'on'); box(ax2,'on');
    xlabel(ax2, xlabels{2}, 'Interpreter','latex');
    % no y-label on the right
    title(ax2, titles{2}, 'Interpreter','latex');

    % Aesthetics + shared y
    axs = [ax1 ax2];
    set(axs, 'FontName','Times New Roman', 'FontSize',9.5, 'LineWidth',0.75, ...
             'TickDir','out', 'Layer','top');
    %axis(ax1,'tight'); axis(ax2,'tight');
    linkaxes(axs,'y');

    % Remove y tick labels on right panel for cleanliness (optional)
    set(ax2,'YTickLabel',[]);

    % Make PDF page exactly figure size (kills big white margins)
    set(f,'PaperUnits','centimeters');
    set(f,'PaperPosition',[0 0 width_cm height_cm]);
    set(f,'PaperSize',[width_cm height_cm]);
    set(f,'PaperPositionMode','manual');

    if ~endsWith(fname,'.pdf','IgnoreCase',true), fname = [fname '.pdf']; end
    print(f, fname, '-dpdf', '-painters', '-r300');

    fprintf('Wrote %s (%.2f x %.2f cm; two panels, R2018b-compatible)\n', ...
            fname, width_cm, height_cm);
end