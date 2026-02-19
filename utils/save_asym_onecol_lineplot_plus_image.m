function save_asym_onecol_lineplot_plus_image(x1,y1,y1b, x2,y2,X,Y,MAT,outpdf,opts)
% One-column composite: grayscale, line-style based, PDF-safe.

    if nargin < 8 || isempty(outpdf), outpdf = 'asym.pdf'; end

    % ----- defaults (grayscale & styles) -----
    opts.fontName = 'Times New Roman'; 
    opts.fontSize = 9.5; 
    opts.lineWidth = 1.25; 
    opts.gridOn = false; 
    opts.showColorbar = true; 
    opts.caxis = []; 
    opts.limsImg = []; 

    % ----- figure geometry -----
    Wcm = 8.8;
    Hcm = 0.8*Wcm;

    f = figure('Units','centimeters','Position',[2 2 Wcm Hcm], ...
        'Color','w','InvertHardcopy','off','Renderer','painters');

    % Layout
    lmargin = 0.14; rmargin = 0.04; bmargin = 0.11; tmargin = 0.08;
    hgap = 0.15; vgap = 0.15;

    leftW  = (1 - lmargin - rmargin - hgap) * 0.4;
    rightW = (1 - lmargin - rmargin - hgap) - leftW;
    fullH  = 1 - bmargin - tmargin;
    halfH  = (fullH - vgap)/2;

    % ================= TOP LEFT =================
    ax1 = axes('Parent',f,'Units','normalized', ...
        'Position',[lmargin, bmargin+halfH+vgap, leftW, halfH]);

    plot(ax1,x1,y1,'k-','LineWidth',opts.lineWidth); hold on
    plot(ax1,x1,y1b,'k--','LineWidth',opts.lineWidth);

    if opts.gridOn, grid on; end
    box on

    %xlabel(ax1,"$\tau (\mu s)$",'Interpreter','latex')
    annotation(f,'textbox', ...
    [ax1.Position(1)+ax1.Position(3)+0.0, ax1.Position(2)-0.065, 0.08, 0.04], ...
    'String','$\tau (\mu s)$','Interpreter','latex', ...
    'EdgeColor','none','Color','k','HorizontalAlignment','right');    
    
    ylabel(ax1,"$V_{L,S} (E_r^{L,S})$",'Interpreter','latex')
    ylim([0 150])
    yticks([0 50 100])
    xticks([0 5 10 15])

    % panel label (a) — top-left INSIDE
%     text(ax1,0.02,0.96,'ticks(a)','Units','normalized',...
%         'FontWeight','normal','Interpreter','latex','VerticalAlignment','top')
    
    annotation(f,'textbox',[ax1.Position(1)-0.075, ax1.Position(2)+ax1.Position(4)-0.01, 0.04, 0.04], ...
    'String','(a)','Interpreter','latex','EdgeColor','none','Color','k','VerticalAlignment','top');
    

    % annotations (grayscale)
    text(ax1,x1(120),y1(120)+25,'$V_S$','Interpreter','latex','Color','k')
    text(ax1,x1(120),y1b(120)-25,'$V_L$','Interpreter','latex','Color','k')

    % ================= BOTTOM LEFT =================
    ax2 = axes('Parent',f,'Units','normalized', ...
        'Position',[lmargin, bmargin, leftW, halfH]);

    plot(ax2,x2,y2,'k:','LineWidth',1.1)
    plot(ax2, x2, y2(:,1), 'k-',  'LineWidth',1.1); hold(ax2,'on')   % main curve: solid black
    %plot(ax2, x2, y2(:,2), 'k--', 'LineWidth',1.0);
    plot(ax2, x2, y2(:,2), 'Color',[0.2 0.2 0.2],  'LineWidth',1.0);
    %plot(ax2, x2, y2(:,4), 'k-.', 'LineWidth',1.0);
    plot(ax2, x2, y2(:,3), 'Color',[0.4 0.4 0.4], 'LineStyle','-', 'LineWidth',1.0);
    plot(ax2, x2, y2(:,4), 'Color',[0.6 0.6 0.6], 'LineStyle','-',  'LineWidth',1.0);    
    
    
    ylim([0 270])
    yticks([0 50 100 150 200])

    if opts.gridOn, grid on; end
    box on
    %axis tight

    %xlabel(ax2,"$x/a_x$",'Interpreter','latex')
    annotation(f,'textbox', ...
    [ax2.Position(1)+ax2.Position(3)+0.01, ax2.Position(2)-0.065, 0.08, 0.04], ...
    'String','$x/a_x$','Interpreter','latex', ...
    'EdgeColor','none','Color','k','HorizontalAlignment','right');       
    
    
    ylabel(ax2,"$V(x,\tau)$",'Interpreter','latex')

    % panel label (b)
%     text(ax2,0.02,0.96,'(b)','Units','normalized',...
%         'FontWeight','normal','Interpreter','latex','VerticalAlignment','top')
    annotation(f,'textbox',[ax2.Position(1)-0.075, ax2.Position(2)+ax2.Position(4)+0.01, 0.04, 0.04], ...
    'String','(b)','Interpreter','latex','EdgeColor','none','Color','k','VerticalAlignment','top');
    
    
    % ================= RIGHT IMAGE =================
    % Right tall image (imagesc with X,Y axes)
    ax3 = axes('Parent',f,'Units','normalized', ...
               'Position',[lmargin+leftW+hgap, bmargin, rightW, fullH]);
    imagesc(ax3, X, Y, MAT);
    set(ax3,'YDir','normal');  % natural Y orientation for data coords
    colormap(ax3, 'default');
    if ~isempty(opts.caxis), caxis(ax3, opts.caxis); end
    if ~isempty(opts.limsImg), axis(ax3, opts.limsImg); else, axis(ax3,'tight'); end
    box(ax3,'on');
%     xlabel(ax3, "$x/a_x$", 'Interpreter','latex');
    annotation(f,'textbox', ...
    [ax3.Position(1)+ax3.Position(3)-0.12, ax3.Position(2)-0.065, 0.08, 0.04], ...
    'String','$x/a_x$','Interpreter','latex', ...
    'EdgeColor','none','Color','k','HorizontalAlignment','right');     
    
%     ylabel(ax3, "$\tau (\mu s)$", 'Interpreter','latex');
axOverlay = axes('Parent',f,'Position',[0 0 1 1],'Visible','off','Units','normalized');

% rotated label placed near the top-left of ax3 (outside its box):
text(axOverlay, ax3.Position(1)-0.09, ax3.Position(2)+ax3.Position(4)-0.13, ...
    '$\tau (\mu s)$', 'Interpreter','latex','Color','k', ...
    'Units','normalized','Rotation',90, ...
    'VerticalAlignment','top','HorizontalAlignment','center');
    title(ax3,  "(c)",  'Interpreter','latex', 'FontWeight','normal');

    % Optional colorbar (kept “eastoutside” within the right axes)
    if opts.showColorbar
        cb = colorbar(ax3,'eastoutside');
        set(cb,'TickLabelInterpreter','latex');
    end

    % ================= UNIFIED STYLING =================
    axs = [ax1 ax2 ax3];
    set(axs,'FontName',opts.fontName,'FontSize',opts.fontSize,...
        'LineWidth',0.75,'TickDir','out','XColor','k','YColor','k')

    for ax = axs
        set(ax,'LooseInset',max(get(ax,'TightInset'),0.02))
    end

    % ================= PDF OUTPUT =================
    set(f,'PaperUnits','centimeters',...
        'PaperPosition',[0 0 Wcm Hcm],...
        'PaperSize',[Wcm Hcm],...
        'PaperPositionMode','manual')

    if ~endsWith(outpdf,'.pdf','IgnoreCase',true)
        outpdf = [outpdf '.pdf'];
    end

    print(f,outpdf,'-dpdf','-painters','-r300')

    fprintf('Wrote %s (%.2f x %.2f cm, grayscale, line-style safe)\n',outpdf,Wcm,Hcm)
end
