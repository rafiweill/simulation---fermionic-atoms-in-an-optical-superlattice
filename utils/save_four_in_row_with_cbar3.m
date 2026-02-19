function save_four_in_row_with_cbar3(imgA, imgB, imgC, imgD, outpdf, span, opts)

    if nargin < 5 || isempty(outpdf), outpdf = 'four_in_row.pdf'; end
    if nargin < 6 || isempty(span),   span   = 'one'; end
    if nargin < 7, opts = struct; end

    % Defaults
    def.tags       = {'(a)','(b)','(c)','(d)'};
    def.cornerText = {'','','',''};
    def.colormap   = 'default';
    def.cbarTicks  = [0 0.2 0.4 0.6 0.8 1];
    def.cbarLabel  = '';
    def.scaleBarPx = [];
    def.scaleBarTxt= '1 \mu m';
    def.scaleBarPos= 'topright';
    def.fontName   = 'Times New Roman';
    def.fontSize   = 9.5;

    % Merge options
    fn = fieldnames(def);
    for k=1:numel(fn)
        if ~isfield(opts, fn{k}) %|| isempty(opts.(fn{k}))
            opts.(fn{k}) = def.(fn{k});
        end
    end

    % Column width
    switch lower(span)
        case 'two', Wcm = 17.8;  % full two-column
        otherwise,  Wcm = 8.6;   % one-column default
    end
    Hcm = 0.28 * Wcm;           % slender row; tweak if needed

    % Read images (allow paths or matrices)
    IA = (imgA);  IB = (imgB);
    IC = (imgC);  ID = (imgD);

    % Figure
    f = figure('Units','centimeters','Position',[2 2 Wcm Hcm], ...
               'Color','w','InvertHardcopy','off','Renderer','painters');

    % Layout (normalized): 4 panels + thin colorbar at right
    lmargin = 0.05; rmargin = 0.08; bmargin = 0.14; tmargin = 0.08;
    hgap = 0.035; cbarW = 0.035;

    axW = (1 - lmargin - rmargin - cbarW - 3*hgap)/4;
    axH = 1 - bmargin - tmargin;
    y0  = bmargin;

    % Helper to place one panel at column c (1..4)
    function ax = placePanel(c, IMG, tagStr, cornerStr)
        x0 = lmargin + (c-1)*(axW + hgap);
        ax = axes('Parent',f,'Units','normalized','Position',[x0 y0 axW axH]);
        %show_img(ax, IMG, 'hot');
        show_img(ax, IMG, 'default');
        axis(ax,'image'); axis(ax,'off');

        % Subfigure tag
        text(ax, 0.02, 0.98, tagStr, 'Units','normalized', ...
             'HorizontalAlignment','left','VerticalAlignment','top', ...
             'FontName','Times New Roman','FontSize',10, ...
             'FontWeight','bold','Color','w','Interpreter','none');

        % Corner text (e.g., times), bottom-left in white
        if ~isempty(cornerStr)
            text(ax, 0.02, 0.02, cornerStr, 'Units','normalized', ...
                 'HorizontalAlignment','left','VerticalAlignment','bottom', ...
                 'FontName','Times New Roman','FontSize',10, ...
                 'Color','w','Interpreter','latex');
        end
    end

    % Panels (a)–(d)
    placePanel(1, IA, '(a)', '$\tau=0$');
    placePanel(2, IB, '(b)', '$0.45\tau_p$');
    placePanel(3, IC, '(c)', '$0.55\tau_p$');
    placePanel(4, ID, '(d)', '$0.75\tau_p$');

    % ---- colorbar axis at right (same height as image axes; labels on RIGHT) ----
    axc = axes('Parent', f, 'Units', 'normalized', ...
               'Position', [1 - 0.6*rmargin - cbarW, 1.6*y0, 0.5*cbarW, 0.8*axH], ...
               'Color', 'none');                       % transparent background

    % Draw a vertical gradient defined on y=0..1 so ticks map directly
    g = linspace(0,1,256)'; 
    gimg = repmat(g,1,8);                              % thin strip
    imagesc(axc, [0 1], [0 1], gimg);                  % x in [0,1], y in [0,1]
    set(axc, 'YDir','normal');                         

    % Axis cosmetics
    set(axc, 'XTick', [], ...
             'YLim', [0 1], ...
             'YTick', [0 0.2 0.4 0.6 0.8 1], ...
             'TickDir', 'out', ...
             'YAxisLocation', 'right', ...             % <<< put labels on the right
             'Box', 'on', ...
             'LineWidth', 0.5, ...
             'TickLabelInterpreter','latex', ...
             'Layer','top');                           % keep ticks above image

    %colormap(axc, hot);

    
%     if ~isempty(opts.cbarLabel)
%         ylabel(axc, opts.cbarLabel, 'Interpreter','latex', ...
%                'FontName',opts.fontName,'FontSize',opts.fontSize);
%     end

    % Fonts
    set(findall(f,'Type','axes'), 'FontName', 'Times New Roman', 'FontSize', 10);

    % Tight PDF
    set(f,'PaperUnits','centimeters');
    set(f,'PaperPosition',[0 0 Wcm Hcm]);
    set(f,'PaperSize',[Wcm Hcm]);
    set(f,'PaperPositionMode','manual');

    if ~endsWith(outpdf,'.pdf','IgnoreCase',true), outpdf=[outpdf '.pdf']; end
    print(f, outpdf, '-dpdf', '-painters', '-r300');

    fprintf('Wrote %s (%.2f x %.2f cm; 4-in-row + cbar)\n', outpdf, Wcm, Hcm);
end

%% ---------- helpers ----------
function IMG = read_img(x)
    if ischar(x) || (isstring(x) && isscalar(x))
        IMG = imread(char(x));
    else
        IMG = x;
    end
end

function show_img(ax, IMG, cmapName)
    if ndims(IMG)==3 && size(IMG,3)==3
        image(ax, IMG);
    else
        imagesc(ax, IMG);
        colormap(ax, cmapName);
        % scale 0..1 if looks like probabilities
        if ~isempty(IMG)
            caxis(ax, [min(IMG(:)) max(IMG(:))]);
        end
    end
end

function draw_scalebar(ax, px, txt, pos, opts)
    % Draw a white scalebar of length 'px' pixels inside axes 'ax'.
    % Determine placement (in data pixels if image object exists).
    hImg = findobj(ax,'Type','image');
    if isempty(hImg), return; end
    xdata = get(hImg(1),'XData'); ydata = get(hImg(1),'YData');
    if numel(xdata)==2, xpix = diff(xdata)/(size(get(hImg(1),'CData'),2)-1);
    else, xpix = 1; end
    if numel(ydata)==2, ypix = diff(ydata)/(size(get(hImg(1),'CData'),1)-1);
    else, ypix = 1; end

    % Padding from edges (in pixels of the image grid)
    pad = 8;
    switch lower(pos)
        case 'topleft'
            x0 = xdata(1) + pad*xpix;          y0 = ydata(1) + pad*ypix;
            y_align = 'top'; y_text = y0 - 6*ypix;
        case 'topright'
            x0 = xdata(end) - (pad+px)*xpix;   y0 = ydata(1) + pad*ypix;
            y_align = 'top'; y_text = y0 - 6*ypix;
        case 'bottomleft'
            x0 = xdata(1) + pad*xpix;          y0 = ydata(end) - pad*ypix;
            y_align = 'bottom'; y_text = y0 + 6*ypix;
        otherwise % 'bottomright'
            x0 = xdata(end) - (pad+px)*xpix;   y0 = ydata(end) - pad*ypix;
            y_align = 'bottom'; y_text = y0 + 6*ypix;
    end

    line(ax, [x0, x0+px*xpix], [y0, y0], 'Color','w','LineWidth',2);
    text(ax, x0+px*xpix, y_text, txt, 'Color','w', 'Interpreter','latex', ...
         'HorizontalAlignment','right','VerticalAlignment',y_align, ...
         'FontName',opts.fontName,'FontSize',opts.fontSize);
end