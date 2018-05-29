function varargout = cryptoportfolio(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @portfoliotool_OpeningFcn, ...
                   'gui_OutputFcn',  @portfoliotool_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

end

function portfoliotool_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    handles.model = Portfolios();
    handles.selection  = [];
    handles.datestringformat = 'dd/mm/yyyy';
    set(handles.figure,'Renderer','OpenGL')
    tab_labels = {' Data-Series ',' Ajustes ',' Crypto-Portafolio '};
    handles.tabcount = length(tab_labels);  % Number of tabs
    for i = 1:handles.tabcount
        eval(['h = handles.axes_tab_',num2str(i),';']);  
        axes(h);
        pos = get(h,'Position');
        set(h,'XLim',[0,pos(3)]);
        set(h,'YLim',[0,pos(4)]);
        set(h,'XTick',[]);
        set(h,'YTick',[]);
        set(h,'XTickLabel',{});
        set(h,'YTickLabel',{});
        patch([0,5,pos(3)-5,pos(3),0],[0,pos(4),pos(4),0,0],[1,1,1]);
        text(pos(3)/2,pos(4)/2+2,tab_labels{i},'HorizontalAlignment','center','FontSize',8,'FontName','MS Sans Serif','Units','pixels');
        c = get(h,'Children');    % make sure we can always click on axes object
        for j = 1:length(c)  
            set(c(j),'HitTest','off');
        end
    end
    clearImportDataPage(handles);
    clearDataSeriesPage(handles);
    clearPortfolioOptimizationPage(handles);
    clearResultsPage(handles);
    tab_handler(1,handles);
    guidata(hObject, handles);

end


function varargout = portfoliotool_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

end


function edit_dataseries_decayfactor_Callback(hObject, eventdata, handles)
    decayfactor = str2double(get(handles.edit_dataseries_decayfactor,'String'));
    if isnan(decayfactor) || isempty(decayfactor) || (decayfactor <= 0) || (decayfactor > 100)
        decayfactor = 99;
        set(handles.edit_dataseries_decayfactor,'String','99');
    end
    handles.model.setDecayFactor(decayfactor/100);
    updateDataSeriesPage(handles) 
end
function edit_dataseries_decayfactor_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function checkbox_dataseries_decayfactor_Callback(hObject, eventdata, handles)
    state = get(handles.checkbox_dataseries_decayfactor,'Value');

    if state
        set(handles.edit_dataseries_decayfactor,'Enable','on');
    else
        set(handles.edit_dataseries_decayfactor,'Enable','off');
    end
    
    if state
        edit_dataseries_decayfactor_Callback(handles.edit_dataseries_decayfactor,[],handles);
    else
        handles.model.setDecayFactor(1);
        updateDataSeriesPage(handles)        
    end
    
end

function disableImportDataPage(handles)
    set(handles.uitable_importedseries_pricesseries,'Enable','off');
    set(handles.uitable_importedseries_pricesseries,'Data',[]);
    set(handles.uitable_importedseries_pricesseries,'RowName',[]);
    set(handles.uitable_importedseries_pricesseries,'ColumnName',[]);
    set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Enable','off');
    set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Value',0);
    set(handles.button_importedseries_accept,'Enable','off');
    pause(0.05);  % give some time to update
    
end

function clearImportDataPage(handles)
    set(handles.uipanel_dataimport_workspace,'Visible','off');
    set(handles.uipanel_dataimport_datafeed,'Visible','off');
    set(handles.uipanel_dataimport_xlsfile,'Visible','off');
    
    [yyyy,mm,dd] = datevec(today);  % predefine date range
    set(handles.edit_dataimport_datafeed_startdate,'String',datestr([yyyy-1,mm,dd,0,0,0],handles.datestringformat));
    set(handles.edit_dataimport_datafeed_enddate,'String',datestr([yyyy,mm,dd,0,0,0],handles.datestringformat));
    set(handles.uipanel_dataimport_datafeed_download,'Visible','off');  % hide download panel
    
    set(handles.popupmenu_dataimport_selectsource,'Value',1);
    popupmenu_dataimport_selectsource_Callback(handles.popupmenu_dataimport_selectsource, [], handles);

    set(handles.uitable_importedseries_pricesseries,'Enable','off');
    set(handles.uitable_importedseries_pricesseries,'Data',[]);
    set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Enable','off');
    set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Value',0);
    set(handles.button_importedseries_accept,'Enable','off');
    
end

function clearDataSeriesPage(handles)
    set(handles.uitable_dataseries_assetselection,'ColumnName',[],'RowName',[],'Data',[]);
    cla(handles.axes_dataseries_returnseries);
    reset(handles.axes_dataseries_returnseries);
    set(handles.axes_dataseries_returnseries,'Visible','off');
    set(handles.checkbox_dataseries_decayfactor,'Value',0);
    set(handles.checkbox_dataseries_logreturns,'Value',0);
    % textocosto
    % textoventa
    % valor_costo_accion
    % valor_venta_accion
    set(handles.textocosto,'Visible','off');
     set(handles.textoventa,'Visible','off');
     set(handles.valor_costo_accion,'Visible','off');
     set(handles.valor_venta_accion,'Visible','off');
    
     set(handles.valor_target_riesgo,'Visible','off');
    set(handles.valor_target_retorno,'Visible','off');
    set(handles.textoretorno,'Visible','off');
    set(handles.textoriesgo,'Visible','off');
    set(handles.checkbox_dataseries_decayfactor,'Enable','off');
    set(handles.checkbox_dataseries_logreturns,'Enable','off');
    
end
function clearPortfolioOptimizationPage(handles)
    set(handles.uitable_portopt_genericconstraints,'Data',[],'ColumnName',[]);
    set(handles.uitable_portopt_boundconstraints,'Data',[]);
    set(handles.uitable_portopt_boundconstraints,'ColumnWidth',{50});
    set(handles.uitable_portopt_boundconstraints,'ColumnFormat',{'numeric'});
    set(handles.uitable_portopt_boundconstraints,'ColumnEditable',true);
    set(handles.button_portopt_addconstraint,'Enable','off');
    set(handles.button_portopt_computeefficientfrontier,'Enable','off');
    
end
function clearResultsPage(handles)
    if strcmp(get(handles.button_results_createreport,'Enable'),'off')
        return
    end
    cla(handles.axes_results_efficientfrontier);
    legend(handles.axes_results_efficientfrontier,'off')
    set(handles.axes_results_efficientfrontier,'Visible','off');
    cla(handles.axes_results_performance);
    legend(handles.axes_results_performance,'off');
    set(handles.axes_results_performance,'Visible','off');
    cla(handles.axes_results_valueatrisk);
    set(handles.axes_results_valueatrisk,'Visible','off');
    axes(handles.axes_results_allocation);
    set(handles.uitable_dataseries_assetselection_aprendizaje,'Visible','off');
    set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Visible','off');
    h = pie(1,{'Seleccionar Portafolio de la frontera Efc.'});
    for i = 1:length(h)
        if strcmp(get(h(i),'Type'),'patch')
            set(h(i),'Visible','off')
        end
    end
    set(handles.uitable_results_weights,'Data',[]);
    set(handles.uitable_results_weights,'ColumnName',[]);
    set(handles.uitable_results_metrics,'Data',[]);
    set(handles.uitable_results_metrics,'ColumnFormat',{'char','char'});
    pos = get(handles.uitable_results_metrics,'Position');
    set(handles.uitable_results_metrics,'ColumnWidth',{135,pos(3)-135-4});
    handles.selection = [];
    guidata(handles.figure,handles);
    set(handles.edit_results_confidencelevel,'Enable','off');
    set(handles.edit_results_riskfreerate,'Enable','off');
    set(handles.popupmenu_results_valueatrisk,'Enable','off');
    set(handles.button_results_createreport,'Enable','off');
    
end

function updateDataSeriesPage(handles)
    if isempty(handles.model.getPrices)
        return
    end
    returns         = handles.model.getReturnSeries;
   dates           = handles.model.getDates;
    assetlabels     = handles.model.getPricesLabels;
    [~,~,~,annualized_ret,annualized_rsk] = handles.model.getStatistics(true);  % annualized stats for all assets
    assetselection  = handles.model.getAssetSelection;
    assetsel_ind    = find(assetselection); % we need linear indices
    
    if isempty(get(handles.uitable_dataseries_assetselection,'Data'))
        set(handles.uitable_dataseries_assetselection,'ColumnEditable',[false,true,false,false]);
        set(handles.uitable_dataseries_assetselection,'ColumnFormat',{'char','logical','char','char'});
        set(handles.uitable_dataseries_assetselection,'RowName',[]);
        set(handles.uitable_dataseries_assetselection,'ColumnName',{'Nombre del activo','Seleccionar','ANL Ren','ANL Vol'});
        data = num2cell([annualized_ret(:),annualized_rsk(:)]);
        for i = 1:numel(data)
            data{i} = [sprintf('%2.2f',data{i}*100),'%'];
        end
        data = [assetlabels(:),repmat({true},length(assetlabels),1),data];
        set(handles.uitable_dataseries_assetselection,'Data',data);
        pos = get(handles.uitable_dataseries_assetselection,'Position');
        if length(assetlabels) < 11
            set(handles.uitable_dataseries_assetselection,'ColumnWidth',{pos(3)-184,60,60,60});
        else
            set(handles.uitable_dataseries_assetselection,'ColumnWidth',{pos(3)-200,60,60,60});
        end
    end
    data = get(handles.uitable_dataseries_assetselection,'Data');
    newstatsdata = num2cell([annualized_ret(:),annualized_rsk(:)]);
    for i = 1:numel(newstatsdata)
        newstatsdata{i} = [sprintf('%2.2f',newstatsdata{i}*100),'%'];
    end
    if sum(any(cellfun(@strcmp,newstatsdata,data(:,3:4))==false)) > 0
        set(handles.uitable_dataseries_assetselection,'Data',[data(:,1:2),newstatsdata]); % replace data in table with new values
    end
    
    plotobjects = get(handles.axes_dataseries_returnseries,'Children');
    if isempty(plotobjects)
        if ~isempty(dates)
            update_xaxis = true;
        else
            update_xaxis = false;
            dates = (0:size(returns,1))';  % dummy date vector
        end
        set(handles.axes_dataseries_returnseries,'XLim',[min(dates),max(dates)]);
        grid(handles.axes_dataseries_returnseries,'on')
        set(handles.axes_dataseries_returnseries,'Box','off');
        hold(handles.axes_dataseries_returnseries,'on');
        set(handles.axes_dataseries_returnseries,'Visible','on');
        title(handles.axes_dataseries_returnseries,'Rendimientos Series (Derecha-click para deseleccionar)');
    else
        update_xaxis = false;
        for i = 1:length(plotobjects)
            delete(plotobjects(i));
        end
    end
    colormap = hsv(length(assetselection));
    if isempty(dates)
        dates = (0:size(returns,1))';  % dummy date vector for plotting
    end
    for i = 1:size(returns,2)
        po = plot(handles.axes_dataseries_returnseries,dates(2:end),returns(:,i),'Color',colormap(assetsel_ind(i),:));
       
        menu = uicontextmenu;  % create context menu
        item = uimenu(menu,'Label',['Deselect ''',assetlabels{i},''''],'Callback',@uimenu_callback);  % define callback
        set(item,'UserData',assetsel_ind(i));   % add asset position in table
        set(po,'UIContextMenu',menu);
    end
    ylimmax = max(abs(returns(:)));
    set(handles.axes_dataseries_returnseries,'YLim',[-ylimmax,ylimmax]);
    if update_xaxis
        datetick(handles.axes_dataseries_returnseries,'x','keeplimits');
    end
    clearResultsPage(handles);
    set(handles.checkbox_dataseries_decayfactor,'Enable','on');
    set(handles.checkbox_dataseries_logreturns,'Enable','on');
    set(handles.checkbox_Costos_Frontera,'Enable','on');
 function uimenu_callback(menu,eventdata)
            assetlabel = get(menu,'UserData');
            enableAsset(handles,assetlabel,false);
        end
end
function updatePortfolioOptimizationPage(handles)
if isempty(handles.model.getPrices)
        return
    end

    set(handles.button_portopt_addconstraint,'Enable','on');
    set(handles.button_portopt_computeefficientfrontier,'Enable','on');
    data = get(handles.uitable_portopt_genericconstraints,'Data');
    
    if isempty(data)
      labels = handles.model.getPricesLabels;
      set(handles.uitable_portopt_genericconstraints,'ColumnName',[labels(:)',{'Op','Valor','Status'}]);
        set(handles.uitable_portopt_genericconstraints,'ColumnFormat',[repmat({[]},1,length(labels)),{{'=','<=','>='},'numeric',{'Enabled','Disabled','Select all','Deselect all','Delete'}}]); 
       set(handles.uitable_portopt_genericconstraints,'ColumnEditable',true);
        set(handles.uitable_portopt_genericconstraints,'ColumnWidth',[repmat({80},1,length(labels)),{50,50,80}]);
        button_portopt_addconstraint_Callback(handles.button_portopt_addconstraint,[],handles); 
    
      
        data = get(handles.uitable_portopt_boundconstraints,'Data');
        if isempty(data)
            set(handles.uitable_portopt_boundconstraints,'Data',[0;1]);
        end
    
    else
        assetselection = handles.model.getAssetSelection;
        columnwidth = [repmat(80,1,length(assetselection)),50,50,80];
        columnwidth(~assetselection) = 0;
        columnwidth = num2cell(columnwidth);
        set(handles.uitable_portopt_genericconstraints,'ColumnWidth',columnwidth);
        set(handles.uitable_portopt_genericconstraints,'ColumnEditable',[assetselection,true,true,true]);
    end
    
    
 
end

function updateResultsPage(handles)

    clearResultsPage(handles);
    handles.selection = [];
    guidata(handles.figure, handles);
    set(handles.edit_results_confidencelevel,'Enable','on');
    set(handles.edit_results_riskfreerate,'Enable','on');
    set(handles.popupmenu_results_valueatrisk,'Enable','on');
    set(handles.button_results_createreport,'Enable','on');
    [~,~,~,annualized_ret,annualized_rsk] = handles.model.getStatistics;
    [~,~,annualized_benchmark_ret,annualized_benchmark_rsk] = handles.model.getBenchmarkStatistics;
    [~,~,pf_weights,annualized_pf_ret,annualized_pf_rsk] = handles.model.getOptimizationResults;
    annualized_ret           = 100*annualized_ret;
    annualized_rsk           = 100*annualized_rsk;
    annualized_benchmark_ret = 100*annualized_benchmark_ret;
    annualized_benchmark_rsk = 100*annualized_benchmark_rsk;
    annualized_pf_ret        = 100*annualized_pf_ret;
    annualized_pf_rsk        = 100*annualized_pf_rsk;
    axes(handles.axes_results_efficientfrontier);
    set(handles.axes_results_efficientfrontier,'Visible','on');
    hold('on');
    plot(annualized_pf_rsk,annualized_pf_ret,'-o','Color','b','MarkerSize',8);
    plot(annualized_rsk,annualized_ret,'*','Color','r','MarkerSize',5);
    legend_str = {'Efficient Portfolios','Individual Assets'};
    if ~isempty(annualized_benchmark_rsk)
        plot(annualized_benchmark_rsk,annualized_benchmark_ret,'^','Color','k')
        legend_str = [legend_str,'Benchmark Portfoliio'];
    end
    grid('on');
    title('Portafolio Seleccionado');
    xlabel('Riesgo anualizado [%]');
    ylabel('Redmientos anualizados [%]');
    h = legend(legend_str,'Location','SouthEast');
    set(h,'UIContextMenu',[]);
    set(h,'HitTest','off');
    set(h,'Box','off')
    el = get(h,'Children');
    for i = 1:length(el) 
        if strcmp(get(el(i),'Type'),'text')
            set(el(i),'BackgroundColor',[1,1,1]);
        end
    end
   
    handles.axes_results_efficientfrontier_legend = h;
    guidata(handles.figure, handles);
    po = plot(annualized_pf_rsk(1),annualized_pf_ret(1),'s','MarkerSize',8,'Color','r','MarkerFaceColor','y');
    set(po,'Visible','off');
    set(po,'Userdata',-1);  % use -1 to find object later
    po = text(annualized_pf_rsk(1),annualized_pf_ret(1),'');
    set(po,'FontSize',8);
    set(po,'BackgroundColor',[1,1,1]);
    set(po,'EdgeColor',[0.8,0.8,0.8])
    set(po,'Visible','off');
    set(po,'Userdata',-2);  
    for i = 1:length(annualized_pf_rsk)
        po = plot(annualized_pf_rsk(i),annualized_pf_ret(i),'bo','MarkerFaceColor','w','MarkerSize',8);
        set(po,'Userdata',i);  % portfolio number
        set(po,'ButtonDownFcn',@portfolioselection_callback);
    end
    for i = 1:length(annualized_rsk)
        po = plot(annualized_rsk(i),annualized_ret(i),'*','Color','r','MarkerSize',5);
        set(po,'Userdata',i);  % asset number
        set(po,'ButtonDownFcn',@assetselection_callback);
    end
    function portfolioselection_callback(hObject,event)
            if ~isempty(handles.selection)
                set(handles.selection,'MarkerFaceColor','none')
                set(handles.selection,'MarkerSize',8)
            end
            set(hObject,'MarkerFaceColor',[0,0.3,0.7])
            set(hObject,'MarkerSize',8)
            handles.selection = hObject; 
            guidata(handles.figure,handles);
            po = get(handles.axes_results_efficientfrontier,'Children');
            for j = 1:length(po)
                if get(po(j),'Userdata') == -1
                    set(po(j),'Visible','off');
                end
                if get(po(j),'Userdata') == -2
                    set(po(j),'Visible','off');
                end
            end
            sel = get(handles.selection,'Userdata');
            weights = pf_weights(sel,:);
            labels  = handles.model.getPricesLabels;
            weights = weights(:);      
            labels  = labels(:);
            ind = abs(weights) > 0.01;
            alloc        = [weights(ind);sum(weights(~ind))];
            alloc_labels = [labels(ind);{'Otros'}];
            if abs(alloc(end)) < 1e-3
                alloc(end) = [];
                alloc_labels(end) = [];
            end
            alloc_labels_weights = [];
            for j = 1:length(alloc_labels)
                alloc_labels_weights{j} = [alloc_labels{j},char(10),num2str(round(alloc(j)*10000)/100),'%'];
            end
            axes(handles.axes_results_allocation);
            h = pie(abs(alloc),alloc_labels_weights);
            for j = 1:length(h)
                if strcmp(get(h(j),'Type'),'text')
                    set(h(j),'FontSize',7);
                end
                if strcmp(get(h(j),'Type'),'patch')
                    set(h(j),'FaceAlpha',0.7);
                    set(h(j),'EdgeAlpha',0.2);
                end
            end
            [alloc,ind] = sort(alloc,'descend');  
            alloc_labels = alloc_labels(ind);
            data = {};
            for j = 1:length(alloc)
                data = [data;[alloc_labels{j},'  (',sprintf('%2.2f',alloc(j)*100),'%)']];
            end
            set(handles.uitable_results_weights,'Data',data);
          
            pos = get(handles.uitable_results_weights,'Position');
            if length(alloc) > 14
                tablewidth = pos(3) - 4 - 16;  
            else
                tablewidth = pos(3) - 4;  
            end
            set(handles.uitable_results_weights,'ColumnWidth',num2cell(tablewidth));


            axes(handles.axes_results_performance);
            set(handles.axes_results_performance,'Visible','on');
            hold('off')
            dates = handles.model.getDates;
            prices = handles.model.getPrices;
            pf_prices = prices*weights;
            pf_prices = 100*pf_prices/abs(pf_prices(1)); 
            if pf_prices(1) < 0
                pf_prices = pf_prices + 200;   
            end
            legend_str = 'Portafolio Seleccionado';
            if ~isempty(dates)
                plot(dates,pf_prices);
                axis('tight');
                datetick('x','keeplimits');
            else
                plot(pf_prices);
            end
            grid('on');
            box('off');
            ylabel('Performance [%]');
            hold('on');
            benchmark = handles.model.getBenchmark;
            if ~isempty(benchmark)
                legend_str = {legend_str,handles.model.getBenchmarkLabel};
                benchmark = 100*benchmark/benchmark(1);   
                if ~isempty(dates)
                    plot(dates,benchmark,'r');
                    axis('tight');
                    datetick('x','keeplimits');
                else
                    plot(benchmark,'r');
                end
            end
            h = legend(legend_str,'Location','NorthWest');
            set(h,'UIContextMenu',[]);
            set(h,'HitTest','off');
            set(h,'Box','off')
            el = get(h,'Children');
            for j = 1:length(el) 
                if strcmp(get(el(j),'Type'),'text')
                    set(el(j),'BackgroundColor',[1,1,1]);
                end
            end
          
            handles.axes_results_performance_legend = h;
            guidata(hObject, handles);
            edit_results_riskfreerate_Callback(handles.edit_results_riskfreerate, [], handles);
            set(handles.axes_results_valueatrisk,'Visible','on');
            edit_results_confidencelevel_Callback(handles.edit_results_confidencelevel, [], handles);
            
            set(handles.uitable_dataseries_assetselection_aprendizaje,'Visible','on');
            set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Visible','on');
           datas = get(handles.uitable_dataseries_assetselection_aprendizaje,'Data');
           datas2 = get(handles.uitable_dataseries_assetselection,'Data');
          
          set(handles.PortafoliosPesosReplica,'ColumnWidth',get(handles.uitable_results_weights,'ColumnWidth'));
           
          set(handles.PortafoliosPesosReplica,'Data',get(handles.uitable_results_weights,'Data'));
           
             datas = datas2; % primero se iguala y despuès se recorta
             for j=1:size(datas2,1)
            
                 if   datas2{j,2} == false
                 datas(j,:)= {'0'};
                
                 end
             end
            datas(cellfun(@(x) strcmp(x,'0'), datas)) = [];
            temporal = datas;
            nn= size(temporal,2);
            nn_renglon = size(temporal,1);
            gg= nn/4;
            a=0;
            if (nn_renglon == 1)
             for j=1:4
                for jj = 1:gg
                   lista(jj,j) = temporal (jj+a);
                   
                end
                 a=a+gg;
             end
            
            
          datas=lista;
            
                
            end
            
           yy=num2str(size(prices,1)); % Se deja 15 para poder comparar en la corrida, pero esto depende de los puntos de aprendizaje
            str = strcat('Maximo para TRN (revisar detalle): ', yy); 
            set(handles.Mensaje,'String',str);
            
           set(handles.DateString,'String',yy);
            
            
            
        
           
           metricaportafolio= get(handles.uitable_results_metrics,'Data');
           
           Tamano_original = size(datas2,1);
           Tamano_modificado = size(datas,1);
           
          
           
          
                  datas = [datas ; 'Portfolio Select',num2cell(true) , metricaportafolio(2,2),metricaportafolio(1,2)  ];
                 priceslabels = get(handles.uitable_importedseries_pricesseries,'ColumnName');
               
                TF = strcmp(datas (1,1),priceslabels{1}); 
                
                if (TF == 0)
                
                    datas = [datas ; priceslabels{1} ,num2cell(true) ,'NX' ,'NX'  ];
                                    
                end
                datas(:,2) =  num2cell(false);
                set(handles.uitable_dataseries_assetselection_aprendizaje,'Data',datas);
                
                 set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data',datas);
           
               
             datas(size(datas,1),3) = metricaportafolio(2,2); %  ; [datas ; 'Portfolio Select',num2cell(true) , metricaportafolio(2,2),metricaportafolio(1,2)  ];
             datas(size(datas,1),4) = metricaportafolio(1,2);
             datas(:,2) =  num2cell(false);
             set(handles.uitable_dataseries_assetselection_aprendizaje,'Data',datas);
             
              set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data',datas);
             
           
        end
    
       
        function assetselection_callback(hObject,event)

           
            selection = get(hObject,'Userdata');
           showMarker(handles,selection)

        end
end


function tab_handler(active_tab,handles)
    for i = 1:handles.tabcount
        h = eval(['handles.axes_tab_',num2str(i)]);
        p = findobj(h,'Type','patch');
        if ~isempty(p)
            if i==active_tab
                set(p,'FaceColor',[1,1,1]);
                eval(['set(handles.uipanel_tab',num2str(i),',''Visible'',''on'');']);
            else
                set(p,'FaceColor',[0.8,0.85,1]);
                eval(['set(handles.uipanel_tab',num2str(i),',''Visible'',''off'');']);
            end
        end
    end
    
    
   if (active_tab == 4)
       set(handles.uipanel_tab1,'Visible','on');
       set(handles.uipanel_dataimport,'Visible','off');
      set(handles.uipanel_importedseries,'Visible','off');
     set(handles.Publicidad1 ,'Visible','on');
   end 
   
  if (active_tab == 5)
       set(handles.uipanel_tab4,'Visible','on');
       
       set(handles.uipanel_tab1,'Visible','on');
            set(handles.uipanel_dataimport,'Visible','off');
              set(handles.uipanel_importedseries,'Visible','off');
       set(handles.Publicidad1 ,'Visible','off');
     
        set(handles.grafica_salida,'Visible','on');
        set(handles.grafica_salida_panel,'Visible','on');
        set(handles.uipanel65,'Visible','on');
        set(handles.uipanel67,'Visible','on'); 
        set(handles.uipanel72,'Visible','on');
  end 
   
   if (active_tab == 6)
       set(handles.uipanel_tab5,'Visible','on');
       
       set(handles.uipanel_tab1,'Visible','on');
       
        set(handles.grafica_salida,'Visible','off');
        set(handles.uipanel65,'Visible','off');
        set(handles.uipanel67,'Visible','off'); 
        set(handles.uipanel72,'Visible','off'); 
        
     set(handles.grafica_salida_panel,'Visible','off'); 
        
         panel1 = get(handles.uipanel75,'Visible');
        if strcmp(panel1,'on')
             panel2 = get(handles.uipanel74,'Visible');
            if strcmp(panel2,'off')
              set(handles.uipanel_dataimport,'Visible','on');
              
            end; 
            set(handles.uipanel_importedseries,'Visible','on'); 
        else
            set(handles.uipanel_dataimport,'Visible','off');
              set(handles.uipanel_importedseries,'Visible','off');
        end;
       set(handles.Publicidad1 ,'Visible','off');
     
   end; 
  
  
  
  
    if (active_tab == 1)
      
       set(handles.uipanel_dataimport,'Visible','on');
      set(handles.uipanel_importedseries,'Visible','on');
       
     
    end; 
   
   
end



function axes_tab_1_ButtonDownFcn(hObject, eventdata, handles)

    tab_handler(1,handles);
end



function axes_tab_2_ButtonDownFcn(hObject, eventdata, handles)

    tab_handler(2,handles);
end


function axes_tab_3_ButtonDownFcn(hObject, eventdata, handles)
    tab_handler(3,handles);
end



function axes_tab_4_ButtonDownFcn(hObject, eventdata, handles)

    tab_handler(4,handles);
end

function axes_tab_5_ButtonDownFcn(hObject, eventdata, handles)

    tab_handler(5,handles);
end


function axes_tab_6_ButtonDownFcn(hObject, eventdata, handles)
    tab_handler(6,handles);
end


function popupmenu_dataimport_selectsource_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popupmenu_dataimport_selectsource_Callback(hObject, eventdata, handles)

    selection = get(handles.popupmenu_dataimport_selectsource,'Value');
    switch selection
        case 1  % MATLAB Workspace
            if strcmp(get(handles.uipanel_dataimport_workspace,'Visible'),'off')
                set(handles.uipanel_dataimport_workspace,'Visible','on');
                set(handles.uipanel_dataimport_datafeed,'Visible','off');
                set(handles.uipanel_dataimport_xlsfile,'Visible','off');
                vars = evalin('base', 'whos');
                var_list_numeric = {};
                var_list_cellstrings = {};
                var_list_strings = {};
                for i = 1:length(vars)
                    if strcmp(vars(i).class, 'double')
                        var_list_numeric = [var_list_numeric; vars(i).name]; 
                    end
                    if strcmp(vars(i).class, 'cell')
                        var_list_cellstrings = [var_list_cellstrings; vars(i).name]; 
                    end
                    if strcmp(vars(i).class, 'char')
                        var_list_strings = [var_list_strings; vars(i).name]; 
                    end
                end
                var_list_dates = sort([var_list_cellstrings;var_list_numeric]);  % dates may be strings or serial
                if ~isempty(var_list_numeric)
                    var_list_numeric = ['Select variable'; var_list_numeric];
                else
                    var_list_numeric = 'No data available';
                end
                if ~isempty(var_list_cellstrings)
                    var_list_cellstrings = ['Select variable'; var_list_cellstrings];
                else
                    var_list_cellstrings = 'No data available';
                end
                if ~isempty(var_list_strings)
                    var_list_strings = ['Select variable'; var_list_strings];
                else
                    var_list_strings = 'No data available';
                end
                if ~isempty(var_list_dates)
                   var_list_dates = ['Select variable'; var_list_dates];
                else
                    var_list_dates = 'No data available';
                end
                set(handles.popupmenu_dataimport_workspace_prices,'String',var_list_numeric)
                set(handles.popupmenu_dataimport_workspace_benchmark,'String',var_list_numeric)
                set(handles.popupmenu_dataimport_workspace_dates,'String',var_list_dates)  
                set(handles.popupmenu_dataimport_workspace_priceslabels,'String',var_list_cellstrings)
                set(handles.popupmenu_dataimport_workspace_benchmarklabel,'String',var_list_strings)
            end
        case 2  % Excel file
            if strcmp(get(handles.uipanel_dataimport_xlsfile,'Visible'),'off')
                set(handles.uipanel_dataimport_xlsfile,'Visible','on');
                set(handles.uipanel_dataimport_workspace,'Visible','off');
                set(handles.uipanel_dataimport_datafeed,'Visible','off');
            end
            
        case 3  % eodhistoricaldata.com Datafeed
            if strcmp(get(handles.uipanel_dataimport_datafeed,'Visible'),'off')
                % Activate panel
                set(handles.uipanel_dataimport_datafeed,'Visible','on');
                set(handles.uipanel_dataimport_workspace,'Visible','off');
                set(handles.uipanel_dataimport_xlsfile,'Visible','off');
            end
    end

end
function popupmenu_dataimport_workspace_prices_Callback(hObject, eventdata, handles)
end

function popupmenu_dataimport_workspace_prices_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popupmenu_dataimport_workspace_benchmark_Callback(hObject, eventdata, handles)
end

function popupmenu_dataimport_workspace_benchmark_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TRN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function DateString_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popupmenu_dataimport_workspace_dates_Callback(hObject, eventdata, handles)
end
function popupmenu_dataimport_workspace_dates_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function button_dataimport_workspace_importdata_Callback(hObject, eventdata, handles)
    set(handles.text_dataimport_workspace_status,'String','');
    disableImportDataPage(handles);
    selection = get(handles.popupmenu_dataimport_workspace_prices,'Value');
    if selection == 1
        set(handles.text_dataimport_workspace_status,'String','Select prices series');
        return
    end
    variable = get(handles.popupmenu_dataimport_workspace_prices,'String');
    variable = variable{selection};
    prices = evalin('base', variable);
    if size(prices,1) < 2 || size(prices,2) < 2
        set(handles.text_dataimport_workspace_status,'String','Prices variable must have at least 2 columns');
        return
    end
    selection = get(handles.popupmenu_dataimport_workspace_benchmark,'Value');
    if selection == 1
        % no benchmark
        benchmark = [];
    else
        variable = get(handles.popupmenu_dataimport_workspace_benchmark,'String');
        variable = variable{selection};
        benchmark = evalin('base', variable);
        
        
        
        
        if isempty(benchmark)
        benchmark = prices(:,1);
        prices = prices(:,2:end);
        priceslabels = evalin('base', variable);
        end
        if ~isvector(benchmark) || length(benchmark) ~= size(prices,1)
            set(handles.text_dataimport_workspace_status,'String',{'Benchmark series must be a vector with same number';'of elements as in each prices series'});
            return
        end
    end
    selection = get(handles.popupmenu_dataimport_workspace_dates,'Value');
    if selection == 1
        dates = [];
    else
        variable = get(handles.popupmenu_dataimport_workspace_dates,'String');
        variable = variable{selection};
        dates = evalin('base', variable);
        if ~isvector(dates) || length(dates) ~= size(prices,1)
            set(handles.text_dataimport_workspace_status,'String',{'Dates series must be a vector with same number';'of elements as in each prices series'});
            return
        end
        selection = get(handles.popupmenu_dataimport_workspace_datestringformat,'Value');
        options   = get(handles.popupmenu_dataimport_workspace_datestringformat,'String');
        datestringformat = options{selection};
        switch datestringformat
            case 'Serial date number (MATLAB)'
            case 'Serial date number (Excel)'
                dates = x2mdate(dates);
            otherwise
                try
                    dates = x2mdate(dates);
                catch
                    set(handles.text_dataimport_workspace_status,'String',{'Date string format does not match'});
                    return
                end
                handles.datestringformat = datestringformat;
                guidata(hObject, handles);
        end
    end
    selection = get(handles.popupmenu_dataimport_workspace_priceslabels,'Value');
    if selection == 1
        num = size(prices,2);  
        labels = cellstr([repmat('Asset ',num,1),num2str((1:num)')]);
        priceslabels = strrep(labels,'  ',' ');
    else
        variable = get(handles.popupmenu_dataimport_workspace_priceslabels,'String');
        variable = variable{selection};
        priceslabels = evalin('base', variable);
        
        if ~isvector(priceslabels) % || length(priceslabels) ~= size(prices,2)
            set(handles.text_dataimport_workspace_status,'String',{'Prices labels series must be a vector with same number';'of elements as prices series'});
            return
        end
    end
    if isempty(benchmark)
        benchmarklabel = [];
    else
        selection = get(handles.popupmenu_dataimport_workspace_benchmarklabel,'Value');
        if selection == 1
           
            benchmarklabel = 'Benchmark Index';
           
        else
            variable = get(handles.popupmenu_dataimport_workspace_benchmarklabel,'String');
            variable = variable{selection};
            benchmarklabel = evalin('base', variable);
            
            if isempty(benchmarklabel)
                benchmarklabel =  priceslabels{1};
                priceslabels(1) = [];
                
             end
 
            if ~ischar(benchmarklabel)
                set(handles.text_dataimport_workspace_status,'String','Benchmark label series must be a string');
                return
            end
        end
    end
    
    updateImportDataPage(handles,prices,benchmark,dates,priceslabels,benchmarklabel);

  set(handles.button_correlation_accept,'Enable','on'); 
   set(handles.cab_grupo,'Enable','on');   
end


function popupmenu_dataimport_workspace_priceslabels_Callback(hObject, eventdata, handles)
end

function popupmenu_dataimport_workspace_priceslabels_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popupmenu_dataimport_workspace_benchmarklabel_Callback(hObject, eventdata, handles)
end

function popupmenu_dataimport_workspace_benchmarklabel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function button_portopt_addconstraint_Callback(hObject, eventdata, handles)
    if isempty(handles.model.getPrices)
        return
    end
    data = get(handles.uitable_portopt_genericconstraints,'Data');
    numassets = length(handles.model.getAssetSelection);
    if isempty(data)
        data = [repmat({true},1,numassets),{'=',1,'Enabled'}];
    else
        data = [data;repmat({false},1,numassets),{'=',1,'Enabled'}];
    end
    set(handles.uitable_portopt_genericconstraints,'Data',data);

end

function button_aprendizajes_Callback(hObject, eventdata, handles)

 [~,~,~,annualized_ret,annualized_rsk] = handles.model.getStatistics;
    [~,~,annualized_benchmark_ret,annualized_benchmark_rsk] = handles.model.getBenchmarkStatistics;
    [~,~,pf_weights,annualized_pf_ret,annualized_pf_rsk] = handles.model.getOptimizationResults;

    
     matrixaprendizaje = handles.model.getPricesaprendizaje;
     prices = handles.model.getPrices;
      
     
            sel = get(handles.selection,'Userdata');
             if strcmp(get(handles.button_results_createreport,'Enable'),'off')
                    weights = handles.model.getweight_salida;  % Significa que lo carga atrvés de load
            
             else 
                    weights = pf_weights(sel,:);
                    weights = weights(:);     
            
             end
             
             pf_prices = prices*weights;
             dates = handles.model.getDates;
             pf_precios_sal = pf_prices;
             weight_salida = weights;
             
             pf_rendimientos = tick2ret(pf_prices,dates,'Simple');
             prices_rendimientos = tick2ret(prices,dates,'Simple');
             matrixaprendizaje = tick2ret(matrixaprendizaje,dates,'Simple');
           
                datas = get(handles.uitable_dataseries_assetselection_aprendizaje,'Data');
                datas2 = get(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data');
           

             priceslabels = get(handles.uitable_importedseries_pricesseries,'ColumnName');
              if strcmp(get(handles.button_results_createreport,'Enable'),'off')
                TF = strcmp(datas (1,1),handles.model.getBenchmark);
              else
                TF = strcmp(datas (1,1),priceslabels{1}); % Solo si se encuentra el indice no al inicio de matriz
              end 
             if strcmp(get(handles.button_results_createreport,'Enable'),'off')
                 indice_inicio= handles.model.getsalida_inicio_precio;
                 datatemp=handles.model.getpf_rendimientos;
              else
                  datatemp = get(handles.uitable_importedseries_pricesseries,'Data');                  
                  indice_inicio=datatemp(1,1);
                  datatemp = tick2ret(datatemp(:,1),dates,'Simple');  %Obtenemos el indice, siempre y cuando no se haya deseleccionado de la primer parte
             end
             
              if ((TF == 0) &&(cell2mat(datas(size(datas,1)-1,2)) == 1))
               matrixaprendizaje = [matrixaprendizaje  pf_rendimientos  ];
              end
              if ((TF == 1) &&(cell2mat(datas(size(datas,1),2)) == 1))
               matrixaprendizaje = [matrixaprendizaje  pf_rendimientos  ];
              end
                  
                if ((TF == 0) &&(cell2mat(datas(size(datas,1),2)) == 1))
                    matrixaprendizaje = [matrixaprendizaje  datatemp(:,1)];
                end 
               
        if ((TF == 0) &&(cell2mat(datas2(size(datas2,1),2)) == 1))
         salida = datatemp(:,1);
         salida_inicio_precio=indice_inicio;
        else
         if ((TF == 0) &&(cell2mat(datas2(size(datas2,1)-1,2)) == 1))
               salida = pf_rendimientos;
              salida_inicio_precio= pf_precios_sal(1);
         else
         if ((TF == 1) &&(cell2mat(datas2(size(datas2,1),2)) == 1))
               salida = pf_rendimientos;  
               salida_inicio_precio=pf_precios_sal(1);
         else
         if (TF == 0)  % Si indice aparece al final
              datas2(size(datas2,1),:) = [ ]; 
               datas2(size(datas2,1),:) = [ ];
                salida  =  prices_rendimientos*cell2mat(datas2(:,2));
                        mm=prices*cell2mat(datas2(:,2));
                salida_inicio_precio=mm(1);
         else
              datas2(size(datas2,1),:) = [ ];  % si indice aparece al inicio
               salida  =  prices_rendimientos*cell2mat(datas2(:,2));
                                    mm=prices*cell2mat(datas2(:,2));
               salida_inicio_precio=mm(1);
         end
         end
         end
        end
         dias_forecast = str2double(get(handles.FORECAST,'String'));
         trn_point =  str2double(get(handles.TRN,'String'));        
         numMFs =  str2double(get(handles.numMFs,'String'));
         numEpochs =  str2double(get(handles.numEpochs,'String'));
        yy=num2str(size(matrixaprendizaje,1)-2*dias_forecast-1);
        str = strcat('Maximo para TRN: ', yy);
        set(handles.Mensaje,'String',str);
         if  (trn_point > size(matrixaprendizaje,1)-2*dias_forecast-1)  % Se deja minimo 2 para poder comparar en la corrida
           yy =  num2str(size(matrixaprendizaje,1)-2*dias_forecast-1);
            str = strcat('ERROR: TRN no puede ser mayor a: ', yy);
            set(handles.Mensaje,'String',str);  
            return
         end 
         if  (trn_point < 10)  % Lo minimo de aprendizaje es 10 para aprendizaje
           yy =  '10';
           str = strcat('ERROR: TRN no puede ser menor a: ', yy);
            set(handles.Mensaje,'String',str);  
            return
         end       
         if  (dias_forecast > 300)  % El forecast lo tenemos abierto a 300 puntos es exagerado!!
           yy =  '300';
             str = strcat('ERROR: Forecast no puede ser mayor a: ', yy);
            set(handles.Mensaje,'String',str);  
             return
         end 
         if  (dias_forecast < 1)  % Lo minimo es 1 dia de forecast
           yy =  '1';
            str = strcat('ERROR: Forecast no puede ser menor a: ', yy);
            set(handles.Mensaje,'String',str);
           return
         end
        
         
          if  (numMFs > 7)  % El numMFs no puede ser mayor a 7!!
           yy =  '7';
            str = strcat('ERROR: numMFs no puede ser mayor a: ', yy);
            set(handles.Mensaje,'String',str);  
             return
         end 
         if  (numMFs < 1)  % Lo minimo es 1 dia de forecast
           yy =  '1';
            str = strcat('ERROR: numMFs no puede ser menor a: ', yy);
            set(handles.Mensaje,'String',str);
           return
         end
         
          if  (numEpochs > 500)  %  no puede ser mayor a 500!!
           yy =  '500';
             str = strcat('ERROR: numEpochs no puede ser mayor a:',yy);
            set(handles.Mensaje,'String',str);  
             return
         end 
         if  (numEpochs < 1)  % Lo minimo es 1 dia de forecast
           yy =  '1';
            str = strcat('ERROR: numEpochs no puede ser menor a: ', yy);
            set(handles.Mensaje,'String',str);
           return
         end
          
         yy= size(matrixaprendizaje,1)-trn_point-1 ;
         set(handles.CHKK,'String',yy);
         salida2 = salida(dias_forecast+1:trn_point+ dias_forecast);
       
         if (sum(salida2)>-50) % Solo para comprobar que si existe una salida
     TRN_APRENDIZAJE = matrixaprendizaje(1:trn_point,:); 
           
         vals = boolean(get(handles.checkbox_ACP,'Value'));
    
            if vals == false
          
                     TRN_CHECK = TRN_APRENDIZAJE;
                     CHK_CHK = matrixaprendizaje(trn_point+1:end-dias_forecast, :); % Esta matriz es la que se revisa
                     TRN_APRENDIZAJE = [TRN_APRENDIZAJE  salida2 ];% Esta matriz va al fuzzy
                   
        
            else
                
                
                [cmp,moyx,Vpr,corr,faccorr,tip]= Acpnew(TRN_APRENDIZAJE,97);   
                cmp = cmp(:,1:tip); % tip es el componente limite que hace el 97% de información
                tipsize=tip;
                 TRN_CHECK = cmp;
                TRN_APRENDIZAJE = [cmp  salida2 ];% Esta matriz que va al fuzzy
       
                               
                    CHK_CHK = matrixaprendizaje(trn_point+1:end-dias_forecast, :); % Esta matriz es la que se revisa 
                   [cmp,moyx,Vpr,corr,faccorr,tip]= Acpnew(CHK_CHK,97); 
                    cmp = cmp(:,1:tipsize);
                    CHK_CHK = cmp;  % Esta es la matriz que es de CHK
            end
        
             TRN_MTX = salida(dias_forecast+1:trn_point+ dias_forecast);% Vector  Entrenamiento para llevarlo a gráfica
             CHK_MTX = salida(trn_point+ dias_forecast+1:end-dias_forecast);% Vector matriz CHK para llevarlo a gráfica
            FORECAST_MTX = salida(end-dias_forecast+1:end);% Vector matriz CHK de los ultimos dias (forecast = 5,4,3,2,1)
        
            fismat=genfis1( TRN_APRENDIZAJE,numMFs);
            [fismat1,error]=anfis( TRN_APRENDIZAJE,fismat,numEpochs);
            acpe = boolean(get(handles.checkbox_ACP,'Value'));
    handles.model.importData2(fismat1, TRN_CHECK, CHK_CHK, TRN_APRENDIZAJE, TRN_MTX, CHK_MTX, FORECAST_MTX, dias_forecast, trn_point, numMFs,numEpochs, acpe,  pf_rendimientos, weight_salida, pf_precios_sal,salida_inicio_precio);             
     
    set(handles.SaveFis,'Enable','on');
    set(handles.Anfis_Edit,'Enable','on');
    set(handles.Mensaje,'String','Aprendizaje Completo');  
 
    set(handles.axes_tab_1,'Visible','off');
    set(handles.axes_tab_2,'Visible','off');
    set(handles.axes_tab_3,'Visible','off');
 
    set(handles.uitable_dataseries_assetselection_aprendizaje,'Enable', 'off');
    set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Enable','off');
    set(handles.numMFs,'Enable','off');
    set(handles.numEpochs,'Enable','off');
    set(handles.TRN,'Enable','off');
    set(handles.FORECAST,'Enable','off');
     set(handles.checkbox_ACP,'Enable','off');

      set(handles.button_aprendizajes,'Enable','off');
     set(handles.LoadFis,'Enable','off');
     set(handles.Anfis_Edit,'Enable','off');
     set(handles.SaveFis,'Enable','on');
     set(handles.checkbox_Cabeza,'Enable','off');

     set(handles.Activar_Pestanas,'Enable','on');
 
     set(handles.SalidaResultados,'ColumnFormat',{'char','char'});
    set(handles.SalidaResultados,'ColumnEditable',[false,false]);       
      set(handles.SalidaResultados,'ColumnName',{'Real','Forecast'});

    set(handles.MetricaSalida,'ColumnFormat',{'char','char'});
    set(handles.MetricaSalida,'ColumnEditable',[false,false]);
     set(handles.MetricaSalida,'RowName',{'Mean','STD','Skewness','Kurtosis'});        
     set(handles.MetricaSalida,'ColumnName',{'Real','Forecast'});

      ii=size(handles.model.getDates,1);
    iii=size(handles.model.getTRN_MTX,1);
    iiii=size(handles.model.getCHK_MTX,1);
    str = strcat('Total.',' ',num2str(ii));
            set(handles.TotalSalida,'String',str);  
    str = strcat('TRN.',' ',num2str(iii));
            set(handles.TRNA,'String',str);  
    str = strcat('CHK.',' ',num2str(iiii));
            set(handles.CHKSALIDA,'String',str);  

    acpi = handles.model.getacpe;

              if acpi == true
               set(handles.ACP_ENTRADA,'Value',1);
              else
                set(handles.ACP_ENTRADA,'Value',0);  
              end
    set(handles.uitable_dataseries_salida,'ColumnEditable',get(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnEditable'));
 
    set(handles.uitable_dataseries_salida,'ColumnFormat',{'char','logical','logical','logical'});
     set(handles.uitable_dataseries_salida,'ColumnEditable',[false,true,false,false]);
 
    set(handles.uitable_dataseries_salida,'RowName',[]);
    set(handles.uitable_dataseries_salida,'ColumnName',{'Nombre del activo','Seleccionar','Aprendizaje', 'Salida'});
     datass = get(handles.uitable_dataseries_assetselection_aprendizaje,'Data');   
    datasss = get(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data'); %ACTIVARLA DESDE APRENDIZAJE O LOAD
    datass = [datass(:,1:2) datass(:,2) datasss(:,2)];
    datass(:,2) =  num2cell(false);
    set(handles.uitable_dataseries_salida,'Data',datass);
    
    
set(handles.MetricaSalida,'Data', []);
set(handles.SalidaResultados,'Data', []);
set(handles.TotalSalida,'Value',0);  
set(handles.CHKSALIDA,'Value',0);  
set(handles.TRNA,'Value',0); 
set(handles.ErrorSalida,'Value',0); 
 set(handles.uipanel74,'Visible','on'); % Se activa panel de correr
        panel1 = get(handles.uipanel75,'Visible');
        if strcmp(panel1,'on')
              set(handles.uipanel_dataimport,'Visible','off');
              set(handles.uipanel_importedseries,'Visible','off'); 
        
        end;
      
    
else
             set(handles.Mensaje,'String','Error: Se tiene que seleccionar la matriz aprendizaje');  
           
         end
end
function button_portopt_computeefficientfrontier_Callback(hObject, eventdata, handles)
    if isempty(handles.model.getPrices)
        return
    end
    set(handles.button_portopt_computeefficientfrontier,'Enable','off');
    drawnow('expose');
    
    clearResultsPage(handles);
    conSet = [];
    assetselection = handles.model.getAssetSelection;
    numAssets = sum(assetselection);
    data = get(handles.uitable_portopt_genericconstraints,'Data');
    data = data(:,[assetselection,true,true,true]);  
    badrows = strcmp(data(:,end),'Disabled');
    data(badrows,:) = [];
    badrows = ~logical(sum(cell2mat(data(:,1:end-3)),2));
    data(badrows,:) = [];
    for i = 1:size(data,1)
        switch data{i,numAssets+1}
            case '<='
                conSet = [conSet;
                          cell2mat(data(i,1:numAssets)),data{i,numAssets+2}];
            case '>='
                conSet = [conSet;
                          -cell2mat(data(i,1:numAssets)),-data{i,numAssets+2}];
            case '='
                conSet = [conSet;
                          cell2mat(data(i,1:numAssets)),data{i,numAssets+2};
                          -cell2mat(data(i,1:numAssets)),-data{i,numAssets+2}];
        end
    end
    data = get(handles.uitable_portopt_boundconstraints,'Data');   
    if isnan(data(1))
        data(1) = 0;
        set(handles.uitable_portopt_boundconstraints,'Data',data);
    end
    if isnan(data(2))
        data(2) = 1;
        set(handles.uitable_portopt_boundconstraints,'Data',data);
    end
    if data(2) < data(1)
        data = [0;1];
        set(handles.uitable_portopt_boundconstraints,'Data',data);
    end
    conSet = [conSet;
              -eye(numAssets),-ones(numAssets,1)*data(1);
              eye(numAssets),ones(numAssets,1)*data(2)];
          
    if strcmp(get(handles.textocosto,'Visible'),'off')
    
    msg = handles.model.computeEfficientFrontier(conSet);
    else
        
      costo =  str2double(get(handles.valor_costo_accion,'String'));
      venta =  str2double(get(handles.valor_venta_accion,'String'));
      retornos =  str2double(get(handles.valor_target_retorno,'String'));
      riesgos =  str2double(get(handles.valor_target_riesgo,'String'));
   
      msg = handles.model.computeEfficientFrontier2(costo,venta, retornos, riesgos);
    end
    
    if ~isempty(msg)
        set(handles.button_portopt_computeefficientfrontier,'Enable','on');    
        msgbox(msg,'Warning');
        return
    end
    updateResultsPage(handles);
    tab_handler(3,handles);
    set(handles.button_portopt_computeefficientfrontier,'Enable','on');    
end
function checkbox_dataseries_logreturns_Callback(hObject, eventdata, handles)
    val = boolean(get(handles.checkbox_dataseries_logreturns,'Value'));
    handles.model.useLogReturns(val);
    updateDataSeriesPage(handles)
end
function popupmenu_dataimport_workspace_datestringformat_Callback(hObject, eventdata, handles)
end
function popupmenu_dataimport_workspace_datestringformat_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function uitable_portopt_genericconstraints_CellEditCallback(hObject, eventdata, handles)
    data = get(handles.uitable_portopt_genericconstraints,'Data');
    if eventdata.Indices(2) ~= size(data,2)
        return
    end
    do_update = false;
    if strcmp(eventdata.NewData,'Delete')
       data(eventdata.Indices(1),:) = []; 
       do_update = true;
    end
    ind = ~cellfun('isempty',strfind({'Select all','Deselect all'},eventdata.NewData));
    if any(ind)
       data(eventdata.Indices(1),1:end-3) = {ind(1)}; 
       data(eventdata.Indices(1),end) = {eventdata.PreviousData}; 
       do_update = true;
    end
    if do_update
        set(handles.uitable_portopt_genericconstraints,'Data',data);
    end

end
function uitable_results_weights_CellSelectionCallback(hObject, eventdata, handles)
    if isempty(eventdata) || isempty(eventdata.Indices)
        return
    end
    selection = eventdata.Indices;
    selection = selection(1);  % only need row index
    sel_label = get(handles.uitable_results_weights,'Data');
    sel_label = sel_label{selection,1};  % extract selected asset label
    ind1 = find(sel_label=='(',1,'first');
    if isempty(ind1)
        return
    end
    sel_label = strtrim(sel_label(1:ind1-1));
    showMarker(handles,sel_label)
    
end
function showMarker(handles,selection)
    po = get(handles.axes_results_efficientfrontier,'Children');
    marker = [];
    markertext = [];
    for i = 1:length(po)
        if get(po(i),'Userdata') == -1
            marker = po(i);
        end
        if get(po(i),'Userdata') == -2
            markertext = po(i);
        end
    end
    if isempty(marker) || isempty(markertext)
        return
    end
    [~,~,~,annualized_ret,annualized_rsk] = handles.model.getStatistics;
    annualized_ret           = 100*annualized_ret;
    annualized_rsk           = 100*annualized_rsk;
    labels      = handles.model.getPricesLabels;
    if ischar(selection)
        ind = find(strcmp(labels,selection));
    else
        ind = selection;
    end
    if ~isempty(ind) && isscalar(ind)
        set(marker,'XData',annualized_rsk(ind),'YData',annualized_ret(ind)); 
        set(marker,'Visible','on');
        set(markertext,'String',labels{ind});
        m_extend = get(markertext,'Extent');
        a_xlim = get(handles.axes_results_efficientfrontier,'XLim');
        final_pos = zeros(1,2);  % place text to the right of marker
        final_pos(1) = annualized_rsk(ind) + range(a_xlim)/40; 
        final_pos(2) = annualized_ret(ind);
        if a_xlim(2) - (final_pos(1) + m_extend(3)) < 0
            final_pos(1) = annualized_rsk(ind) - range(a_xlim)/40 - m_extend(3);
        end
        set(markertext,'Position',final_pos);
        set(markertext,'Visible','on');
    else
        set(marker,'Visible','off');
        set(markertext,'Visible','off');
    end    
end


function edit_results_riskfreerate_Callback(hObject, eventdata, handles)
    selection = get(handles.selection,'Userdata');  
    if isempty(selection)
        return
    end
    riskfreerate = str2double(get(handles.edit_results_riskfreerate,'String'));
    if isnan(riskfreerate)
        riskfreerate = 2;
        set(handles.edit_results_riskfreerate,'String','2');
    end
    metrics = handles.model.getPerformanceMetrics(selection, riskfreerate/100);
    if isempty(metrics)
        return
    end
    if isempty(handles.model.getBenchmark)
        data = {'Volatilidad Anualizada',[sprintf('%2.2f',100*metrics.annualizedvolatility),'%']; ...
                'Rendimiento Anualizado',[sprintf('%2.2f',100*metrics.annualizedreturn),'%']; ...
                'Correlación','-'; ...
                'Sharpe Ratio',sprintf('%2.2f',metrics.sharperatio); ...
                'Alpha','-'; ...
                'Risk-adjusted Return','-'; ...
                'Informacion Ratio','-'; ...
                'Tracking Error','-'; ...
                'Max. Drawdown',[sprintf('%2.2f',100*metrics.maxdrawdown),'%']};
    else
        data = {'Volatilidad Anualizada',[sprintf('%2.2f',100*metrics.annualizedvolatility),'%']; ...
                'Rendimiento Anualizado',[sprintf('%2.2f',100*metrics.annualizedreturn),'%']; ...
                'Correlación',sprintf('%2.2f',metrics.correlation); ...
                'Sharpe Ratio',sprintf('%2.2f',metrics.sharperatio); ...
                'Alpha',[sprintf('%2.2f',100*metrics.alpha),'%']; ...
                'Risk-adjusted Return',[sprintf('%2.2f',100*metrics.riskadjusted_return),'%']; ...
                'Informacion Ratio',[sprintf('%2.2f',100*metrics.inforatio),'%']; ...
                'Tracking Error',[sprintf('%2.2f',100*metrics.trackingerror),'%']; ...
                'Max. Drawdown',[sprintf('%2.2f',100*metrics.maxdrawdown),'%']};
    end    
    set(handles.uitable_results_metrics,'Data',data,'ColumnName',[]);
    
end
function edit_results_riskfreerate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit_results_confidencelevel_Callback(hObject, eventdata, handles)
    selection = get(handles.selection,'Userdata');  
    if isempty(selection)
        return
    end
    confidence_level = str2double(get(handles.edit_results_confidencelevel,'String'));
    if isnan(confidence_level)
        confidence_level = 95;
        set(handles.edit_results_confidencelevel,'String','95');
    end
    option = get(handles.popupmenu_results_valueatrisk,'Value');
    if option == 1
        handles.model.computeHistoricalVaR(selection,confidence_level/100,handles.axes_results_valueatrisk);
    else
        handles.model.computeParameticVaR(selection,confidence_level/100,handles.axes_results_valueatrisk);
    end

end
function edit_results_confidencelevel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popupmenu_results_valueatrisk_Callback(hObject, eventdata, handles)
    edit_results_confidencelevel_Callback(handles.edit_results_confidencelevel, [], handles);
    
end 
function popupmenu_results_valueatrisk_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function button_results_createreport_Callback(hObject, eventdata, handles)
    DisableReporting = false;  % set to true to disable reporting
    ExcelSheetVisible = true;  % set to true to keep Excel sheet visible during reporting process
     FileName = 'C:\MATLAB\Portafoliocorrida\Report.xlsx';
    SheetName = 'Summary';
    Overwrite = true;
    if Overwrite && exist(FileName,'file')
        delete(FileName);
    end
    opts_txt_normal = ExcelReport.getDefaultTextOptions;
    opts_txt_normal.FontSize = 11;
    opts_txt_title1 = ExcelReport.getDefaultTextOptions;
    opts_txt_title1.Bold = true;
    opts_txt_title1.FGColor = [0.15,0.15,0.15];
    opts_txt_title1.FontSize = 20;
    opts_txt_title2 = opts_txt_title1;
    opts_txt_title2.FontSize = 14;
    opts_txt_title3 = opts_txt_title1;
    opts_txt_title3.FontSize = 12;
    opts_table_data = ExcelReport.getDefaultTableOptions;
    opts_table_data.MajorGrid = true;
    opts_table_data.MinorGrid = true;
    opts_table_data.GridColor = [0.2,0.2,0.2];
    opts_table_data.HorizontalAlignment = 'center';
    opts_table_data.Title.Grid = true;
    opts_table_data.Title.GridColor = [0.2,0.2,0.2];
    report = ExcelReport(FileName,SheetName,DisableReporting,ExcelSheetVisible);
    report.setOrientation('Landscape')
    report.setColumnWidth('A:ZZ',3.1);
    report.setRowHeight('1:1000',15);
    row_count = 1;
    report.insertText([row_count,1],'Reporte de Distribución de la cartera',opts_txt_title1);
    [~,s] = weekday(today,'long');
    report.insertText([row_count + 1,1],[' ',s,', ',datestr(today,handles.datestringformat)],opts_txt_normal);
    report.insertPicture([row_count,50],'C:\MATLAB\Portafoliocorrida\marca.png',[137,120]);
    row_count = row_count + 3;
    report.insertText([row_count,1],'Configuración Optimización',opts_txt_title2);
    row_count = row_count + 2;
    data = get(handles.uitable_portopt_boundconstraints,'Data');   
    report.insertText([row_count,1],'Límites de activos',opts_txt_title3);
    report.insertText([row_count+2,1],['Lower límite:  ',sprintf('%2i',data(1)*100),'%'],opts_txt_normal);
    report.insertText([row_count+3,1],['Upper límite:  ',sprintf('%2i',data(2)*100),'%'],opts_txt_normal);
    report.setRowHeight(num2str(row_count+1),5);
    data = get(handles.uitable_portopt_genericconstraints,'Data');
    assetselection = handles.model.getAssetSelection;
    data = data(:,[assetselection,true,true,true]);  
    badrows = strcmp(data(:,end),'Disabled');
    data(badrows,:) = [];
    badrows = ~logical(sum(cell2mat(data(:,1:end-3)),2));
    data(badrows,:) = [];
    priceslabels = handles.model.getPricesLabels();
    constraints = {};
    for row = 1:size(data,1)
        ind = cell2mat(data(row,1:end-3));
        if all(ind)
            txt = 'Suma de todos los activos';
        else
            labels = priceslabels(cell2mat(data(row,1:end-3)));
            txt = labels{1};
            for count = 2:length(labels)
                if mod(count,10) == 1
                    constraints{end+1} = txt;
                    txt = '';
                end
                txt = [txt,'  +  ',labels{count}];
            end
        end
        txt = [txt,'  ',data{row,end-2},'  ',[sprintf('%2i',data{row,end-1}*100),'%']];
        constraints{end+1} = txt;
    end
    if ~isempty(constraints)
        report.insertText([row_count,9],'Restricciones',opts_txt_title3);
        for el = 1:length(constraints)
            report.insertText([row_count+1+el,9],constraints{el},opts_txt_normal);
        end
        report.setRowHeight([num2str(row_count+2),':',num2str(row_count+1+length(constraints))],17);
    end
    row_count = row_count + max(5,length(constraints)+4);
    report.insertText([row_count,1],'Resultados de Optimización',opts_txt_title2);
    row_count = row_count + 2;
 report.insertFigure([row_count,1],[handles.axes_results_efficientfrontier,handles.axes_results_efficientfrontier_legend])
    report.insertText([row_count,20],'Resumen de la cartera',opts_txt_title3);
    [~, pf_rsk, pf_weights,annualizedreturn,annualizedvolatility] = handles.model.getOptimizationResults();
    priceslabels = handles.model.getPricesLabels();
    pf_weights = pf_weights';
    skip = sum(abs(pf_weights),2) < 0.01; % do not display unused assets
    pf_weights(skip,:) = [];
    priceslabels(skip) = [];
    data = [1:length(pf_rsk);annualizedvolatility';annualizedreturn';pf_weights];
    data = num2cell(data);
    for row = 1:size(data,1)
        for col = 1:size(data,2)
            if row == 1
                data{row,col} = num2str(data{row,col});
            else
                if abs(data{row,col}) < 0.01
                    data{row,col} = '-';
                else
                    data{row,col} = [sprintf('%2.2f',data{row,col}*100),'%'];
                    if strcmp(data{row,col}(end-3:end),'.00%')  % remove trailing zeros
                        data{row,col}(end-3:end-1) = [];
                    end
                end
            end
        end
    end
    data = [[{'Portafolio #';'Volatilidad Anualizada';'Rendimiento anualizado'};priceslabels(:)],data];
    opts_table_data.MergeNumberOfColumns = [6,2*ones(1,size(data,2)-1)];
    opts_table_data.FontSize = 9;
    report.insertTable([row_count+2,20],data(1:3,:),'Desempeno',opts_table_data);
    report.insertTable([row_count+6,20],data(4:end,:),'Pesos',opts_table_data);
    row_count = row_count + max(15,size(data,1)+5);
    if ~isempty(handles.selection)
        sel = get(handles.selection,'Userdata');
        report.insertText([row_count,1],['Seleccion Portafolio #',num2str(sel)],opts_txt_title2);
        row_count = row_count + 2;
        report.insertText([row_count,1],'Asignación',opts_txt_title3);
        data = get(handles.uitable_results_weights,'Data'); 
        for i = 1:size(data,1)
            ind1 = find(data{i,1}=='(',1,'last');
            ind2 = find(data{i,1}==')',1,'last');
            if ~isempty(ind1) && ~isempty(ind2)
                data{i,2} = data{i,1}(ind1+1:ind2-1);
                data{i,1} = strtrim(data{i,1}(1:ind1-1));
            end
        end
        opts_table_data.MergeNumberOfColumns = [7,2];
        report.insertTable([row_count + 2,1],data,[],opts_table_data);
  report.insertFigure([row_count + 2,11],handles.axes_results_allocation)
        report.insertText([row_count,23],'Desempeno',opts_txt_title3);
   report.insertFigure([row_count + 2,23],[handles.axes_results_performance,handles.axes_results_performance_legend],[350,220])
        report.insertText([row_count,38],'Métricas',opts_txt_title3);
        data = get(handles.uitable_results_metrics,'Data');
        opts_table_data.MergeNumberOfColumns = [5,2];
        report.insertTable([row_count + 3,38],data,[],opts_table_data);
     report.insertFigure([row_count + 1,46],handles.axes_results_valueatrisk,[280,260]);
        
    end
    report.setFitToPage();
   report.createPDF('C:\MATLAB\Portafoliocorrida\Report.pdf'); %Report.pdf');
    report.closeReport();
   winopen('C:\MATLAB\Portafoliocorrida\Report.pdf')

end
function popupmenu_dataimport_datafeed_indexname_Callback(hObject, eventdata, handles)
end
function popupmenu_dataimport_datafeed_indexname_CreateFcn(hObject, eventdata, handles)
 [~,~,indices] = xlsread('ArchivoIndices');
set(hObject,'String',indices);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end
end
function button_dataimport_datafeed_fetchsymbols_Callback(hObject, eventdata, handles)
    set(handles.uipanel_dataimport_datafeed_download,'Visible','off');
    set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','off');
    set(handles.text_dataimport_datafeed_symbollookup_status,'String','Bajando en proceso.')
    indexname = cellstr(get(handles.popupmenu_dataimport_datafeed_indexname,'String'));
    selection = get(handles.popupmenu_dataimport_datafeed_indexname,'Value');
    indexname = indexname{selection};
    ind = find(indexname=='(',1,'first'); % remove description in brackets
    if ~isempty(ind)
        indexdesc = strtrim(indexname(ind+1:end-1));
        indexname = strtrim(indexname(1:ind-1));
    end
    try 
      
       
       selection2 = get(handles.popupmenu_dataimport_selectsource,'Value');
        if (selection2 == 4) % NO VA PASAR  A ESTA OPCION PUESTO QUE RETIRAMOS YAHOO
        
        h = actxserver('internetexplorer.application');
        h.Visible = 0;

        symbols = {};
        pagecount = 0;
        done = false;
        while ~done
            h.Navigate(['http://finance.yahoo.com/q/cp?s=',indexname,'&c=',num2str(pagecount)]);
            pause(0.2);
            entry = now;
            while ((h.Busy ~= 0) || ~strcmp(h.readyState,'READYSTATE_COMPLETE')) && (now-entry)*24*60*60 < 15
                pause(0.2)
            end
            txt = get(handles.text_dataimport_datafeed_symbollookup_status,'String');
            set(handles.text_dataimport_datafeed_symbollookup_status,'String',[txt,'.']);
            done = true;
            tables = h.Document.documentElement.getElementsByTagName('table');
            for t = 0:tables.length-1
                if tables.item(t).cells.length >= 10
                    % continue with next page
                    done = false;
                    % get row elements
                    for r = 0:tables.item(t).rows.length-1
                        if tables.item(t).rows.item(r).cells.length >= 2
                            symb      = strtrim(tables.item(t).rows.item(r).cells.item(0).innerText);
                            label     = strtrim(tables.item(t).rows.item(r).cells.item(1).innerText);
                            if r == 0
                                if ~strcmp(symb,'Symbol') && ~strcmp(label,'Name')
                                    break
                                end
                            else
                                if ~any(isspace(symb)) && ~isempty(label) && ~strcmpi(label,'n/a')
                                    symbols = [symbols;{symb,label}];
                                end
                            end
                        end
                    end
                end
            end
            pagecount = pagecount + 1;
        end
        if ~isempty(symbols)
            [~,n] = unique(symbols(:,1));
            symbols = symbols(n,:);
            symbols = [{indexname,indexdesc};symbols];  
        end
        h.Quit;
       else
           
            [~,~,symbols] = xlsread('ArchivoSimbolos');
            set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
            if ~isempty(symbols)
            [~,n] = unique(symbols( :,1));
            symbols = symbols(n,:);
            symbols = [{indexname,indexdesc};symbols];  
            end
        end    
            
       
    catch ME
        set(handles.text_dataimport_datafeed_symbollookup_status,'String',ME.message)
        set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
        return
    end
    set(handles.uitable_dataimport_datafeed_symbols,'ColumnFormat',[{[]},'char','char']);
    pos = get(handles.uitable_dataimport_datafeed_symbols,'Position');
    if size(symbols,1) > 22
        set(handles.uitable_dataimport_datafeed_symbols,'ColumnWidth',{40,60,pos(3)-120});
    else
        set(handles.uitable_dataimport_datafeed_symbols,'ColumnWidth',{40,60,pos(3)-104});
    end
    set(handles.uitable_dataimport_datafeed_symbols,'ColumnEditable',[true,false,false]);
    set(handles.uitable_dataimport_datafeed_symbols,'ColumnName',{'','Symbol','Name'});
    data = [repmat({true},size(symbols,1),1),symbols];
    set(handles.uitable_dataimport_datafeed_symbols,'Data',data);
    if ~isempty(symbols)
        set(handles.text_dataimport_datafeed_symbollookup_status,'String','Finished!')
    else
        set(handles.text_dataimport_datafeed_symbollookup_status,'String','No symbols found!')
    end
    set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
    if ~isempty(symbols)
        set(handles.uipanel_dataimport_datafeed_download,'Title',[indexdesc,' Bajando Componentes']);
        set(handles.uipanel_dataimport_datafeed_download,'Visible','on');
        set(handles.text_dataimport_datafeed_download_status,'String','');
        set(handles.text_dataimport_datafeed_download_errorstatus,'String','');
    end
    
end
function button_dataimport_datafeed_downloadseries_CallbackORIGINAL(hObject, eventdata, handles)
    set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','off');
    disableImportDataPage(handles);
    set(handles.text_dataimport_datafeed_download_status,'String','');
    set(handles.text_dataimport_datafeed_download_errorstatus,'String','');
    button_text = get(handles.button_dataimport_datafeed_downloadseries,'String');
    if strcmp('Cancelado',button_text)
        set(handles.button_dataimport_datafeed_downloadseries,'String','Cancelando..');
        drawnow expose;
        return
    end
    tabledata = get(handles.uitable_dataimport_datafeed_symbols,'Data');
    selection = cell2mat(tabledata(:,1));
    symbols = tabledata(:,2);
    priceslabels = tabledata(:,3);
    symbols = symbols(selection);
    priceslabels = priceslabels(selection);
    if length(symbols) < 3
        set(handles.text_dataimport_datafeed_download_status,'String','Please select at least 3 series from list');
        set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
        return
    end
    startdate = get(handles.edit_dataimport_datafeed_startdate,'String');
    enddate = get(handles.edit_dataimport_datafeed_enddate,'String');
    try   
        startdate = datenum(startdate,handles.datestringformat);
        enddate = datenum(enddate,handles.datestringformat);
    catch ME
        set(handles.text_dataimport_datafeed_download_status,'String',['Start/End dates requiere formato: ',handles.datestringformat]);
        set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
        return
    end
    if (enddate - startdate) < 7
        set(handles.text_dataimport_datafeed_download_status,'String','Date rango es menor a una semana');
        set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
        return
    end
    set(handles.button_dataimport_datafeed_downloadseries,'String','Cancelado');
    set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
    drawnow expose;
    try
        y = yahoo;
        %y = blp;
        i = 0;   % loop counter
        while (i < length(symbols)) && ...
              ~strcmp('Cancelando..',get(handles.button_dataimport_datafeed_downloadseries,'String'))
            i = i + 1;  
            set(handles.text_dataimport_datafeed_download_status,'String',['Bajando item ',num2str(i),'/',num2str(length(symbols))]);
            drawnow expose;
            try
                data = fetch(y,symbols{i},'Close',startdate,enddate);
            catch ME
                err_msg = get(handles.text_dataimport_datafeed_download_errorstatus,'String');
                err_msg{end+1,1} = ['Bajando item ',priceslabels{i},' falla']; 
                set(handles.text_dataimport_datafeed_download_errorstatus,'String',err_msg);
                data = [];
            end
            if ~isempty(data)
                if i == 1
                    rawseries = data;
                    rawlabels = priceslabels(i);
                else
                    [common_dates,ind_rawseries,ind_data] = intersect(rawseries(:,1),data(:,1));
                    rawseries(ind_rawseries,end+1) = data(ind_data,2);
                    rawlabels{end+1,1} = priceslabels{i};
                end
            end
            pause(0.05);
        end
    catch ME
        set(handles.text_dataimport_datafeed_download_status,'String',ME.message);
        set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
        set(handles.button_dataimport_datafeed_downloadseries,'String','Bajando Serie Precios');
        set(handles.button_dataimport_datafeed_downloadseries,'Enable','on');
        return
    end
    set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
    set(handles.button_dataimport_datafeed_downloadseries,'String','Bajando Serie Precios');
    set(handles.button_dataimport_datafeed_downloadseries,'Enable','on');
    if i < length(symbols)
        set(handles.text_dataimport_datafeed_download_status,'String','Cancelado');
        return
    end
       
    set(handles.text_dataimport_datafeed_download_status,'String','Download completo!');
    rawseries = sortrows(rawseries,1);
    ind = sum(rawseries==0 | isnan(rawseries)) > 5;
    
    rawseries(:,ind) = [];
    ind =ind(2:end); % NEW 
    rawlabels(ind)   = [];
    
    [row,col] = find(rawseries==0 | isnan(rawseries));
 for i = 2:(size(row)-1)
        if ((rawseries(row(i),col(i)) == 0 || isnan(rawseries(row(i),col(i))))&& (row(i) < size(rawseries,1))  )
         
             if (rawseries(row(i)-1,col(i)-1) > 0 && ~isnan(rawseries(row(i)-1,col(i)-1)))  %rawseries(row(i+1),col(i+1)) > 0)
             if (rawseries(row(i)+1,col(i)+1) > 0 && ~isnan(rawseries(row(i)+1,col(i)+1)))
                    mm= rawseries(row(i)-1,col(i)-1);
                    mm2 = rawseries(row(i)+1,col(i)+1);
                    mm3 = (mm+mm2)/2;
                    rawseries(row(i), col(i)) = mm3;
             
             else
               rawseries(row(i), col(i)) = rawseries(row(i)-1, col(i)-1);
             end
           else
               rawseries(i,:) = 0;
           end
        end
  end
     [row,col] = find(rawseries==0 | isnan(rawseries));
    rawseries(row,:) = []; %NO LO BORRAMOS HASTA INTYERPOLAR PARA NO
    dates  = rawseries(:,1);
    if (selection(1) == true) 
        index  = rawseries(:,2);
        indexlabel = rawlabels{1};
        prices = rawseries(:,3:end);
        priceslabels = rawlabels(2:end);
    else
        index = [];
        indexlabel = [];
        prices = rawseries(:,2:end);
        priceslabels = rawlabels;
    end
     save(['C:\MATLAB\Portafoliocorrida\datafeed_import ',datestr(now,'yyyymmddHHMM')],'prices','index','dates','priceslabels','indexlabel');
     
    updateImportDataPage(handles,prices,index,dates,priceslabels,indexlabel);
    set(handles.button_correlation_accept,'Enable','on'); 
   set(handles.cab_grupo,'Enable','on'); 
end

function button_dataimport_datafeed_downloadseries_Callback(hObject, eventdata, handles)
    set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','off');

    disableImportDataPage(handles);
    set(handles.text_dataimport_datafeed_download_status,'String','');
    set(handles.text_dataimport_datafeed_download_errorstatus,'String','');
    button_text = get(handles.button_dataimport_datafeed_downloadseries,'String');
    if strcmp('Cancelado',button_text)
        set(handles.button_dataimport_datafeed_downloadseries,'String','Cancelando..');
        drawnow expose;
        return
    end
    tabledata = get(handles.uitable_dataimport_datafeed_symbols,'Data');
    selection = cell2mat(tabledata(:,1));
    symbols = tabledata(:,2);
    priceslabels = tabledata(:,3);
    symbols = symbols(selection);
    priceslabels = priceslabels(selection);
    if length(symbols) < 3
        set(handles.text_dataimport_datafeed_download_status,'String','Please select at least 3 series from list');
        set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
        return
    end
    startdate = get(handles.edit_dataimport_datafeed_startdate,'String');
    enddate = get(handles.edit_dataimport_datafeed_enddate,'String');
    try   
         ind=find(startdate=='/');
         DiaStart = startdate(1:ind(1)-1);
         MesStart = startdate(ind(1)+1:ind(end)-1);
          X = str2num(MesStart)-1;
          MesStart = num2str(X);
         AnoStart = startdate(ind(end)+1:end);
          End2=find(enddate=='/');
         DiaEnd = enddate(1:End2(1)-1);
         MesEnd = enddate(End2(1)+1:End2(end)-1);
          X = str2num(MesEnd)-1;
          MesEnd= num2str(X);
         AnoEnd = enddate(End2(end)+1:end);
         
        startdate = datenum(startdate,handles.datestringformat);
        
        enddate = datenum(enddate,handles.datestringformat);
        
    catch ME
        set(handles.text_dataimport_datafeed_download_status,'String',['Start/End dates requiere formato: ',handles.datestringformat]);
        set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
        return
    end
    if (enddate - startdate) < 7
        set(handles.text_dataimport_datafeed_download_status,'String','Date rango es menor a una semana');
        set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
        return
    end
    set(handles.button_dataimport_datafeed_downloadseries,'String','Cancelado');
    set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
    drawnow expose;
    try
        i = 0; 
        
        while (i < length(symbols)) && ...
              ~strcmp('Cancelando..',get(handles.button_dataimport_datafeed_downloadseries,'String'))
            i = i + 1;  
            set(handles.text_dataimport_datafeed_download_status,'String',['Bajando item ',num2str(i),'/',num2str(length(symbols))]);
            drawnow expose;
            try
                
                 url = strcat('http://eodhistoricaldata.com/api/table.csv?s=', symbols{i})
                url = strcat (url,'.CC&api_token=5af6fb8e44e048.17258139&a=');
                url = strcat (url,  MesStart);  % 05
                url = strcat(url, '&b=');
                url = strcat (url, DiaStart); % 12
                url = strcat(url, '&c=');
                url = strcat(url, AnoStart); % 2016
                url = strcat(url, '&d=');
                url = strcat(url, MesEnd); % 05
                url = strcat(url, '&e=');
                url = strcat(url, DiaEnd); %16
                url=strcat(url,'&f=');
                url = strcat(url, AnoEnd); %2017
                url = strcat(url,'&g=d'); % Del 2016,06 (Junio), 12  AL  2017, 06 (Junio), 16
                
                    [s,status] = urlread(url,'Timeout',60);
                    C = textscan(s, '%s%f%f%f%f%f%f', 'HeaderLines', 1, 'delimiter', ',', 'CollectOutput', 0);
               Dattes = C{1};
               Dattes(length(Dattes))=[];
               data = [datenum(Dattes),C{5}];
            catch ME
                err_msg = get(handles.text_dataimport_datafeed_download_errorstatus,'String');
                err_msg{end+1,1} = ['Bajando item ',priceslabels{i},' falla']; 
                set(handles.text_dataimport_datafeed_download_errorstatus,'String',err_msg);
                data = [];
            end
            if ~isempty(data)
                if i == 1
                    rawseries = data;
                    rawlabels = priceslabels(i);
                else
                    [common_dates,ind_rawseries,ind_data] = intersect(rawseries(:,1),data(:,1));
                    rawseries(ind_rawseries,end+1) = data(ind_data,2); % 2 estaba
                    rawlabels{end+1,1} = priceslabels{i};
                end
            end
            pause(0.05);
        end
    catch ME
        set(handles.text_dataimport_datafeed_download_status,'String',ME.message);
        set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
        set(handles.button_dataimport_datafeed_downloadseries,'String','Bajando Serie Precios');
        set(handles.button_dataimport_datafeed_downloadseries,'Enable','on');
        return
    end
    set(handles.button_dataimport_datafeed_fetchsymbols,'Enable','on');
    set(handles.button_dataimport_datafeed_downloadseries,'String','Bajando Serie Precios');
    set(handles.button_dataimport_datafeed_downloadseries,'Enable','on');
    if i < length(symbols)
        set(handles.text_dataimport_datafeed_download_status,'String','Cancelado');
        return
    end
    set(handles.text_dataimport_datafeed_download_status,'String','Download completo!');
    rawseries = sortrows(rawseries,1);
ind = sum(rawseries==0 | isnan(rawseries)) > 5;
    
    rawseries(:,ind) = [];
    ind =ind(2:end); % NEW 
    rawlabels(ind)   = [];
    [row,col] = find(rawseries==0 | isnan(rawseries));
 for i = 2:(size(row)-1)
        if ((rawseries(row(i),col(i)) == 0 || isnan(rawseries(row(i),col(i))))&& (row(i) < size(rawseries,1))  )
         
             if (rawseries(row(i)-1,col(i)-1) > 0 && ~isnan(rawseries(row(i)-1,col(i)-1)))  %rawseries(row(i+1),col(i+1)) > 0)
             if (rawseries(row(i)+1,col(i)+1) > 0 && ~isnan(rawseries(row(i)+1,col(i)+1)))
                    mm= rawseries(row(i)-1,col(i)-1);
                    mm2 = rawseries(row(i)+1,col(i)+1);
                    mm3 = (mm+mm2)/2;
                    rawseries(row(i), col(i)) = mm3;
             
             else
               rawseries(row(i), col(i)) = rawseries(row(i)-1, col(i)-1);
             end
           else
               rawseries(i,:) = 0;
           end
        end
  end
     [row,col] = find(rawseries==0 | isnan(rawseries));
    rawseries(row,:) = []; %NO LO BORRAMOS HASTA INTYERPOLAR PARA NO
    dates  = rawseries(:,1);
    if (selection(1) == true) 
        index  = rawseries(:,2);
        indexlabel = rawlabels{1};
        prices = rawseries(:,3:end);
        priceslabels = rawlabels(2:end);
    else
        index = [];
        indexlabel = [];
        prices = rawseries(:,2:end);
        priceslabels = rawlabels;
    end
     save(['C:\MATLAB\Portafoliocorrida\datafeed_import ',datestr(now,'yyyymmddHHMM')],'prices','index','dates','priceslabels','indexlabel');
    
    updateImportDataPage(handles,prices,index,dates,priceslabels,indexlabel);
    set(handles.button_correlation_accept,'Enable','on'); 
   set(handles.cab_grupo,'Enable','on'); 
    
end
function updateImportDataPage(handles,prices,benchmark,dates,priceslabels,benchmarklabel)
    if ~isempty(benchmark)
        series = [benchmark(:),prices];
        serieslabels = [benchmarklabel,priceslabels(:)'];
        set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Value',1);  % valid benchmark as first column
    else
        series = prices;
        serieslabels = priceslabels;
        set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Value',0);  % no benchmark
    end
    set(handles.uitable_importedseries_pricesseries,'ColumnName',serieslabels,'Data',series);
    if ~isempty(dates)
        datesstr = cellstr(datestr(dates,handles.datestringformat));
        set(handles.uitable_importedseries_pricesseries,'RowName',datesstr);
    else
        set(handles.uitable_importedseries_pricesseries,'RowName',[]);
    end
    set(handles.uitable_importedseries_pricesseries,'Enable','on');
    set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Enable','on');
    set(handles.button_importedseries_accept,'Enable','on');
    
end


function edit_dataimport_datafeed_startdate_Callback(hObject, eventdata, handles)
end
function edit_dataimport_datafeed_startdate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit_dataimport_datafeed_enddate_Callback(hObject, eventdata, handles)
end

function edit_dataimport_datafeed_enddate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function button_dataimport_datafeed_download_selectall_Callback(hObject, eventdata, handles)
    tabledata = get(handles.uitable_dataimport_datafeed_symbols,'Data');
    if ~isempty(tabledata)
        tabledata(:,1) = {true};
        set(handles.uitable_dataimport_datafeed_symbols,'Data',tabledata);
    end
end
function button_dataimport_datafeed_download_deselectall_Callback(hObject, eventdata, handles)
    tabledata = get(handles.uitable_dataimport_datafeed_symbols,'Data');
    if ~isempty(tabledata)
        tabledata(2:end,1) = {false};
        set(handles.uitable_dataimport_datafeed_symbols,'Data',tabledata);
    end
end

function button_dataimport_excelfile_import_Callback(hObject, eventdata, handles)
    set(handles.text_dataimport_excelfile_status,'String','');    
    disableImportDataPage(handles);
    
    filename = get(handles.edit_dataimport_excelfile_filename,'String');
    if isempty(filename)
        set(handles.text_dataimport_excelfile_status,'String','Please provide Excel filename');
        return
    end
    if ~exist(filename,'file')
        set(handles.text_dataimport_excelfile_status,'String','Can''t find file specified');
        return
    end
    
    sheetname = get(handles.edit_dataimport_excelfile_sheetname,'String');
    try
        if isempty(sheetname)
            [~,~,rawdata] = xlsread(filename);
        else
            [~,~,rawdata] = xlsread(filename,sheetname);
        end
    catch ME
        set(handles.text_dataimport_excelfile_status,'String',ME.message);
        return
    end
   
     
    if isempty(rawdata)
        set(handles.text_dataimport_excelfile_status,'String','Worksheet is empty');
        return
    end
    
    if (size(rawdata,1) < 10) || (size(rawdata,2) < 4)
        set(handles.text_dataimport_excelfile_status,'String','Worksheet contains too few data');
        return
    end
    datesheadername = get(handles.edit_dataimport_excelfile_datesheadername,'String');
    ind = find(strcmp(rawdata(1,:),datesheadername));
    if ~isempty(ind) && isscalar(ind)
        dates = rawdata(2:end,ind);
        rawdata(:,ind) = [];
        if ~isnumeric(dates{1})
            datestringformat = cellstr(get(handles.popupmenu_dataimport_excelfile_dateformat,'String'));
            sel = get(handles.popupmenu_dataimport_excelfile_dateformat,'Value');
            datestringformat = datestringformat{sel};
            
            try
                dates = datenum(dates,datestringformat);
            catch ME
                set(handles.text_dataimport_excelfile_status,'String',ME.message);
                return
            end
            handles.datestringformat = datestringformat;
            guidata(hObject, handles);
        end
    else
        dates = [];
    end
    if isempty(dates)
        msg = ['Note: No date header with name "',datesheadername,'" found'];
        set(handles.text_dataimport_excelfile_status,'String',msg);
    end
    prices = rawdata(2:end,:);
    priceslabels = rawdata(1,:);
    bad_el = cellfun(@ischar,prices(:,1)) == true; % is it non-numeric?
    for i = 1:size(prices,1)
        if (bad_el(i) == false) && (~isscalar(prices{i,1}) || isnan(prices{i,1}))
            bad_el(i) = true;
        end
    end
    if all(bad_el)
        prices(:,1) = [];
        priceslabels(1) = [];
    end
    [row,col] = find(cellfun(@isnumeric,prices) == false);
    prices(row,:) = [];  
    prices = cell2mat(prices);
    updateImportDataPage(handles,prices,[],dates,priceslabels,[]);
  
    set(handles.button_correlation_accept,'Enable','on'); 
   set(handles.cab_grupo,'Enable','on'); 
    
end


function edit_dataimport_excelfile_datesheadername_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function edit_dataimport_excelfile_sheetname_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit_dataimport_excelfile_filename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function button_dataimport_excelfile_browse_Callback(hObject, eventdata, handles)
    [filename,pathname] = uigetfile({'*.xlsx;*.xls','Excel File'},'Please select file');
    if ~isequal(filename,0)
        set(handles.edit_dataimport_excelfile_filename,'String',fullfile(pathname,filename));
    end

end


function popupmenu_dataimport_excelfile_dateformat_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end 
function uitable_dataseries_assetselection_CellEditCallback(hObject, eventdata, handles)
    indices = eventdata.Indices;
    if indices(2) == 2
        enableAsset(handles,indices(1),eventdata.NewData);
    end
end
function uitable_dataimport_datafeed_symbols_CellEditCallback(hObject, eventdata, handles)
 indices = eventdata.Indices;
 data = get(handles.uitable_dataimport_datafeed_symbols,'Data');
    if indices(1,1) == 1
        data(indices(1),1) = {true};
        set(handles.uitable_dataimport_datafeed_symbols,'Data',data);
    end

end




function uitable_dataseries_assetselection_apre_sal_CellEditCallback(hObject, eventdata, handles)
 indices = eventdata.Indices;
    state=   eventdata.NewData;
data = get(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data');
sel = cell2mat(data(:,2));
if (sum(sel) == 1) && (state == true)
    
        data(indices(1),2) = {true};
        set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data',data);
else
        data(indices(1),2) = {false};
        set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data',data);
end
end
function uitable_dataseries_assetselection_apre_CellEditCallback(hObject, eventdata, handles)
 indices = eventdata.Indices;
    state=   eventdata.NewData;
data = get(handles.uitable_dataseries_assetselection_aprendizaje,'Data');
sel = cell2mat(data(:,2));
if (sum(sel) == 6) && (state == true)  % aqui entraria el acp
    set(handles.checkbox_ACP,'Value',1);  % Se activa automaticamente el ACP
else
end
handles.model.enableAssetaprendizaje(indices(1),state);
end
function enableAsset(handles,asset,state)
    data = get(handles.uitable_dataseries_assetselection,'Data');
    if data{asset,2} ~= state
        data{asset,2} = state;
        set(handles.uitable_dataseries_assetselection,'Data',data);
    end
    sel = cell2mat(data(:,2));
    if (sum(sel) == 1) && (state == false)
        data(asset,2) = {true};
        set(handles.uitable_dataseries_assetselection,'Data',data);
        return
    end
    handles.model.enableAsset(asset,state);
    updateDataSeriesPage(handles);
    updatePortfolioOptimizationPage(handles);
end

function button_correlation_accept_Callback(hObject, eventdata, handles)
 serieslabels = get(handles.uitable_importedseries_pricesseries,'ColumnName');
 Data = get(handles.uitable_importedseries_pricesseries,'Data');
 seriecor = get(handles.uitable_importedseries_pricesseries,'Data');
NombreRenglon = get(handles.uitable_importedseries_pricesseries,'RowName');
  button_text = get(handles.button_correlation_accept,'String');
    if strcmp('Correlación',button_text)
        set(handles.button_correlation_accept,'String','Regresar..');
         set(handles.uitable_importedseries_pricesseries,'RowName',serieslabels);
 
         seriecorr = corrcoef(seriecor);
        set(handles.uitable_importedseries_pricesseries,'Enable','on');
        set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Enable','off');
        set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Value',0);
        set(handles.button_importedseries_accept,'Enable','off');
        pause(0.05);         
        
         set(handles.uitable_importedseries_pricesseries,'ColumnName',serieslabels,'Data',seriecorr );
    
          set(handles.cab_grupo,'Enable','off');
    else
        
         if strcmp(get(handles.uipanel_dataimport_datafeed,'Visible'),'on')
        %if get(handles.uipanel_dataimport_datafeed, 'Enabled')
        
        set(handles.button_correlation_accept,'String','Correlación');
        
        
        set(handles.uitable_importedseries_pricesseries,'Data',[]);
    %set(handles.uitable_importedseries_pricesseries,'RowName',[]);
    set(handles.uitable_importedseries_pricesseries,'ColumnName',[]);
    %set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Enable','off');
    %set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Value',0);
    %set(handles.button_importedseries_accept,'Enable','off');
    pause(0.05);  % give some time to update
        
        
        
        %set(handles.uitable_importedseries_pricesseries,'ColumnName',serieslabels,'Data',Data,'RowName',NombreRenglon);
   button_dataimport_datafeed_downloadseries_Callback(hObject, eventdata, handles);
   
    
   
   
   
   
    %set(handles.button_correlation_accept,'Enable','on'); 
   set(handles.cab_grupo,'Enable','on'); 
    
   
   
         end
        
         
        
          if strcmp(get(handles. uipanel_dataimport_xlsfile,'Visible'),'on')
        %if get(handles.uipanel_dataimport_datafeed, 'Enabled')
        
        set(handles.button_correlation_accept,'String','Correlación');
        
        
        set(handles.uitable_importedseries_pricesseries,'Data',[]);
    %set(handles.uitable_importedseries_pricesseries,'RowName',[]);
    set(handles.uitable_importedseries_pricesseries,'ColumnName',[]);
    %set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Enable','off');
    %set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Value',0);
    %set(handles.button_importedseries_accept,'Enable','off');
    pause(0.05);  % give some time to update
        
    
     button_dataimport_excelfile_import_Callback(hObject, eventdata, handles);
  
          end
         
          
           if strcmp(get(handles. uipanel_dataimport_workspace,'Visible'),'on')
        %if get(handles.uipanel_dataimport_datafeed, 'Enabled')
        
        set(handles.button_correlation_accept,'String','Correlación');
        
        
        set(handles.uitable_importedseries_pricesseries,'Data',[]);
    %set(handles.uitable_importedseries_pricesseries,'RowName',[]);
    set(handles.uitable_importedseries_pricesseries,'ColumnName',[]);
    %set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Enable','off');
    %set(handles.checkbox_importedseries_usefirstcolasbenchmark,'Value',0);
    %set(handles.button_importedseries_accept,'Enable','off');
    pause(0.05);  % give some time to update
        
    
     button_dataimport_workspace_importdata_Callback(hObject, eventdata, handles);
  
          end
          
          
          
          
    end
  %set(handles.uitable_importedseries_pricesseries,'ColumnName',serieslabels,'Data',seriecorr );
   %set(handles.uitable_importedseries_pricesseries,'ColumnName',serieslabels,'Data',Data,'RowName',NombreRenglon);

end


% --- Executes on button press in checkbox_Costos_Frontera_Callback.
function checkbox_Costos_Frontera_Callback(hObject, eventdata, handles)
% 

   
    val = boolean(get(handles.checkbox_Costos_Frontera,'Value'));
    
    if val == true
       % uitable_portopt_genericconstraints
       % uitable_portopt_boundconstraints
       %  button_portopt_addconstraint
       set(handles.uitable_portopt_genericconstraints,'Enable','off');
        set(handles.uitable_portopt_boundconstraints,'Enable','off');
         set(handles.button_portopt_addconstraint,'Enable','off');
         
          set(handles.textocosto,'Visible','on');
     set(handles.textoventa,'Visible','on');
     set(handles.valor_costo_accion,'Visible','on');
     set(handles.valor_venta_accion,'Visible','on');
    set(handles.valor_target_riesgo,'Visible','on');
    set(handles.valor_target_retorno,'Visible','on');
    set(handles.textoretorno,'Visible','on');
    set(handles.textoriesgo,'Visible','on');
         
         
         
    else
        set(handles.uitable_portopt_genericconstraints,'Enable','on');
        set(handles.uitable_portopt_boundconstraints,'Enable','on');
         set(handles.button_portopt_addconstraint,'Enable','on');
         
         
          set(handles.textocosto,'Visible','off');
     set(handles.textoventa,'Visible','off');
     set(handles.valor_costo_accion,'Visible','off');
     set(handles.valor_venta_accion,'Visible','off');
    
         set(handles.valor_target_riesgo,'Visible','off');
    set(handles.valor_target_retorno,'Visible','off');
    set(handles.textoretorno,'Visible','off');
    set(handles.textoriesgo,'Visible','off');
         
    end
    
    
   % handles.model.checkbox_Costos_Frontera(val);
    
    % Update visualization
    
end







function button_importedseries_accept_Callback(hObject, eventdata, handles)

    data = get(handles.uitable_importedseries_pricesseries,'Data');
    if isempty(data)
        return
    end
    priceslabels = get(handles.uitable_importedseries_pricesseries,'ColumnName');
    if get(handles.checkbox_importedseries_usefirstcolasbenchmark,'Value')
        
        benchmark = data(:,1);
        prices = data(:,2:end);
        benchmarklabel = priceslabels{1};
        priceslabels(1) = [];
    else
       
        benchmark = [];
        prices = data;
        benchmarklabel = '';
    end
    dates = get(handles.uitable_importedseries_pricesseries,'RowName');
    if ~isempty(dates)
        dates = datenum(dates,handles.datestringformat);    
    end
    
   
    handles.model.importData(prices,benchmark,dates,priceslabels,benchmarklabel)
   
   
    clearDataSeriesPage(handles);
    updateDataSeriesPage(handles);
    
 
    clearPortfolioOptimizationPage(handles);
    updatePortfolioOptimizationPage(handles);
    
 
    clearResultsPage(handles);
    
   
    tab_handler(2,handles);


    %handles.uitable_dataseries_assetselection_aprendizaje = handles.uitable_dataseries_assetselection;
     set(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnEditable',get(handles.uitable_dataseries_assetselection,'ColumnEditable'));
        
set(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnFormat',get(handles.uitable_dataseries_assetselection,'ColumnFormat'));
set(handles.uitable_dataseries_assetselection_aprendizaje,'RowName',get(handles.uitable_dataseries_assetselection,'RowName'));
set(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnName',get(handles.uitable_dataseries_assetselection,'ColumnName'));
set(handles.uitable_dataseries_assetselection_aprendizaje,'Data',get(handles.uitable_dataseries_assetselection,'Data'));
     
     

set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'ColumnEditable',get(handles.uitable_dataseries_assetselection,'ColumnEditable'));
        
set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'ColumnFormat',get(handles.uitable_dataseries_assetselection,'ColumnFormat'));
set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'RowName',get(handles.uitable_dataseries_assetselection,'RowName'));
set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'ColumnName',get(handles.uitable_dataseries_assetselection,'ColumnName'));
%temporal1=get(handles.uitable_dataseries_assetselection,'ColumnName');
%temporal1=temporal1(1:2);
%set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'ColumnName',temporal1);

Datas = get(handles.uitable_dataseries_assetselection,'Data');
 % datas = [datas ; 'Portfolio Select',num2cell(true) , metricaportafolio(2,2),metricaportafolio(1,2)  ]; 
Datas(:,2) =  num2cell(false);
Datas = Datas(:,1:2);

set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data',Datas);
     
%uitable_results_weights     
     
set(handles.PortafoliosPesosReplica,'ColumnEditable',get(handles.uitable_results_weights,'ColumnEditable'));
        
set(handles.PortafoliosPesosReplica,'ColumnFormat',get(handles.uitable_results_weights,'ColumnFormat'));
set(handles.PortafoliosPesosReplica,'RowName',get(handles.uitable_results_weights,'RowName'));
set(handles.PortafoliosPesosReplica,'ColumnName',get(handles.uitable_results_weights,'ColumnName'));
set(handles.PortafoliosPesosReplica,'Data',get(handles.uitable_results_weights,'Data'));
%PortafoliosPesosReplica   
    
     
     
     
     
     
     
    
end


function checkbox_importedseries_usefirstcolasbenchmark_Callback(hObject, eventdata, handles)

end


function uitable_importedseries_pricesseries_CellEditCallback(hObject, eventdata, handles)

end


function popupmenu_dataimport_selectsource_KeyPressFcn(hObject, eventdata, handles)
end
function button_dataimport_datafeed_fetchsymbols_ButtonDownFcn(hObject, eventdata, handles)
end



function valor_costo_accion_Callback(hObject, eventdata, handles)
end


function valor_costo_accion_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function valor_venta_accion_Callback(hObject, eventdata, handles)
end


function valor_venta_accion_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function valor_target_retorno_Callback(hObject, eventdata, handles)

end
function valor_target_retorno_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function valor_target_riesgo_Callback(hObject, eventdata, handles)

end

function valor_target_riesgo_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end 
function checkbox_ACP_Callback(hObject, eventdata, handles)

val = boolean(get(handles.checkbox_Cabeza,'Value'));
    
           % if val == true
           %    set(handles.checkbox_ACP,'Value',0);
           % end
end


function DateString_Callback(hObject, eventdata, handles)

end

function TRN_Callback(hObject, eventdata, handles)

end

function TRNA_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end




function FORECAST_Callback(hObject, eventdata, handles)

end
function FORECAST_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


end



function CHKK_Callback(hObject, eventdata, handles)

end

function CHKK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function numMFs_Callback(hObject, eventdata, handles)

end
function numMFs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function mfType_Callback(hObject, eventdata, handles)
end

function mfType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function numEpochs_Callback(hObject, eventdata, handles)

end
function numEpochs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function Activar_Pestanas_Callback(hObject, eventdata, handles)
str = strcat('Listo para nuevo aprendizaje!', ' ');
        set(handles.Mensaje,'String',str);  
set(handles.ACP_ENTRADA,'Value',0);                
 panel1 = get(handles.uipanel75,'Visible');
 if strcmp(panel1,'off')
              
            set(handles.axes_tab_1,'Visible','on');
            set(handles.axes_tab_2,'Visible','on');
            set(handles.axes_tab_3,'Visible','on');
 end;

 
 set(handles.uitable_dataseries_assetselection_aprendizaje,'Enable', 'on');
set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Enable','on');
 

set(handles.numMFs,'Enable','on');
set(handles.numEpochs,'Enable','on');
set(handles.TRN,'Enable','on');
set(handles.FORECAST,'Enable','on');
 set(handles.checkbox_ACP,'Enable','on');


 set(handles.button_aprendizajes,'Enable','on');
 set(handles.LoadFis,'Enable','on');
 set(handles.Anfis_Edit,'Enable','on');
 set(handles.SaveFis,'Enable','on');
 set(handles.checkbox_Cabeza,'Enable','on');

 set(handles.PortafoliosPesosReplica,'Enable','on');

datass = get(handles.uitable_dataseries_assetselection_aprendizaje,'Data');   
datasss = get(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data'); %ACTIVARLA DESDE APRENDIZAJE O LOAD
datass(:,2) =  num2cell(false);
datasss(:,2) =  num2cell(false);
set(handles.uitable_dataseries_assetselection_aprendizaje,'Data',datass);
set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data',datasss);

end

function LoadFis_Callback(hObject, eventdata, handles)

try
  fismat1 = evalin('base', 'fismat1');
    TRN_CHECK = evalin('base', 'TRN_CHECK');
    CHK_CHK = evalin('base', 'CHK_CHK');
    TRN_APRENDIZAJE = evalin('base', 'TRN_APRENDIZAJE');
    TRN_MTX = evalin('base', 'TRN_MTX');
    CHK_MTX = evalin('base', 'CHK_MTX');
    FORECAST_MTX = evalin('base', 'FORECAST_MTX');
    dias_forecast = evalin('base', 'dias_forecast');
    trn_point = evalin('base', 'trn_point');
    numMFs = evalin('base', 'numMFs');
    numEpochs = evalin('base', 'numEpoch');
    acpe = evalin('base', 'acpe');
    pf_rendimientos = evalin('base', 'pf_rendimientos'); 
    prices = evalin('base', 'prices');
    dates = evalin('base', 'dates');

    benchmark = evalin('base', 'benchmark');
    priceslabels = evalin('base', 'priceslabels');
    benchmarklabel = evalin('base', 'benchmarklabel');
    datas = evalin('base', 'datas');
    datas2 = evalin('base', 'datas2');
    datasRow= evalin('base', 'datasRow');
    datasCol= evalin('base', 'datasCol');
    dataPort = evalin('base', 'dataPort'); %get(handles.PortafoliosPesosReplica,'Data');
    pf_precios_sal = evalin('base','pf_precios_sal');
    weight_salida = evalin('base', 'weight_salida');
    salida_inicio_precio = evalin('base', 'salida_inicio_precio'); % precio del vector salida precio para calcular el precio del vector y no solo retornos
  
if (acpe == 1)
     set(handles.checkbox_ACP,'Value',1);
end

        handles.model.importData2(fismat1, TRN_CHECK, CHK_CHK, TRN_APRENDIZAJE, TRN_MTX, CHK_MTX, FORECAST_MTX, dias_forecast, trn_point, numMFs,numEpochs, acpe,  pf_rendimientos, weight_salida,pf_precios_sal,salida_inicio_precio );             
        handles.model.importData(prices,benchmark,dates,priceslabels,benchmarklabel);   

   set(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnFormat',{'char','logical','char','char'});
    set(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnEditable',[false,true,false,false]);
    set(handles.uitable_dataseries_assetselection_aprendizaje,'RowName',datasRow);
    set(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnName',datasCol);
    set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'ColumnFormat',{'char','logical','char','char'});
    set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'ColumnEditable',[false,true,false,false]);
    set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'RowName',datasRow);
    set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'ColumnName',datasCol); 
    set(handles.uitable_dataseries_assetselection_aprendizaje,'Data', datas);
    set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data',datas2);
    set(handles.uitable_dataseries_assetselection_aprendizaje,'Enable', 'off');
    set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Enable','off');
    set(handles.PortafoliosPesosReplica,'Enable','off');
    set(handles.uitable_dataseries_assetselection_aprendizaje,'Visible', 'on');
    set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Visible', 'on');

    set(handles.PortafoliosPesosReplica,'RowName',[]);
    set(handles.PortafoliosPesosReplica,'ColumnName',[]);
    pos = get(handles.PortafoliosPesosReplica,'Position');
    set(handles.PortafoliosPesosReplica,'ColumnWidth',{135,pos(3)-135-4});  
    set(handles.PortafoliosPesosReplica,'Data',dataPort);

    set(handles.numMFs,'String',numMFs);
    set(handles.numEpochs,'String',numEpochs);
    set(handles.TRN,'String',trn_point);
    set(handles.FORECAST,'String',dias_forecast);

    set(handles.numMFs,'Enable','off');
    set(handles.numEpochs,'Enable','off');
    set(handles.TRN,'Enable','off');
    set(handles.FORECAST,'Enable','off');
    set(handles.axes_tab_1,'Visible','off');
    set(handles.axes_tab_2,'Visible','off');
    set(handles.axes_tab_3,'Visible','off');
     set(handles.uitable_dataseries_assetselection_aprendizaje,'Enable', 'off');
    set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Enable','off');
    set(handles.numMFs,'Enable','off');
    set(handles.numEpochs,'Enable','off');
    set(handles.TRN,'Enable','off');
    set(handles.FORECAST,'Enable','off');
    set(handles.checkbox_ACP,'Enable','off');
    set(handles.button_aprendizajes,'Enable','off');
    set(handles.LoadFis,'Enable','off');
    set(handles.Anfis_Edit,'Enable','off');
    set(handles.SaveFis,'Enable','off');
    set(handles.checkbox_Cabeza,'Enable','off');
    set(handles.Activar_Pestanas,'Enable','on');
 
 
 
    set(handles.SalidaResultados,'ColumnFormat',{'char','char'});
    set(handles.SalidaResultados,'ColumnEditable',[false,false]);        
    set(handles.SalidaResultados,'ColumnName',{'Real','Forecast'});
    set(handles.MetricaSalida,'ColumnFormat',{'char','char'});
    set(handles.MetricaSalida,'ColumnEditable',[false,false]);
    set(handles.MetricaSalida,'RowName',{'Mean','STD','Skewness','Kurtosis'});
    set(handles.MetricaSalida,'ColumnName',{'Real','Forecast'});

 
      ii=size(handles.model.getDates,1);
    iii=size(handles.model.getTRN_MTX,1);
    iiii=size(handles.model.getCHK_MTX,1);
    str = strcat('Total.',' ',num2str(ii));
    set(handles.TotalSalida,'String',str);  
    str = strcat('TRN.',' ',num2str(iii));
        set(handles.TRNA,'String',str);  
    str = strcat('CHK.',' ',num2str(iiii));
        set(handles.CHKSALIDA,'String',str);  
        
    acpi = handles.model.getacpe;

  
              if acpi == true
               set(handles.ACP_ENTRADA,'Value',1);
              else
                set(handles.ACP_ENTRADA,'Value',0);  
              end
    set(handles.uitable_dataseries_salida,'ColumnEditable',get(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnEditable'));
 
    set(handles.uitable_dataseries_salida,'ColumnFormat',{'char','logical','logical','logical'});
    set(handles.uitable_dataseries_salida,'ColumnEditable',[false,true,false,false]);
 
    set(handles.uitable_dataseries_salida,'RowName',[]);
    set(handles.uitable_dataseries_salida,'ColumnName',{'Nombre del activo','Seleccionar','Aprendizaje', 'Salida'});
    datass = get(handles.uitable_dataseries_assetselection_aprendizaje,'Data');   
    datasss = get(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data'); %ACTIVARLA DESDE APRENDIZAJE O LOAD
    datass = [datass(:,1:2) datass(:,2) datasss(:,2)];
    datass(:,2) =  num2cell(false);

    set(handles.uitable_dataseries_salida,'Data',datass);

 
    set(handles.Mensaje,'String','Se ha cargado las variables en el sistema a través del Workspace, se ha inabilitado las primeras 3 pestanas'); 
 
 
     set(handles.button_results_createreport,'Enable','off'); % Se pone inactivo enabled

      set(handles.uipanel74,'Visible','on'); % Se activa panel de correr
      
   
        panel1 = get(handles.uipanel75,'Visible');
        if strcmp(panel1,'on')
              set(handles.uipanel_dataimport,'Visible','off');
              set(handles.uipanel_importedseries,'Visible','off'); 
        
        end;
      
     
      
clear;


catch
    
    set(handles.Mensaje,'String','Error: Se debe cargar variables en el Workspace');
          return
 end

end

function SaveFis_Callback(hObject, eventdata, handles)
fismat1 = handles.model.getfismat;
    TRN_CHECK = handles.model.getTRN_CHECK;
    CHK_CHK = handles.model.getCHK_CHK;
    TRN_APRENDIZAJE =  handles.model.getTRN_APRENDIZAJE;
    TRN_MTX = handles.model.getTRN_MTX;
    CHK_MTX = handles.model.getCHK_MTX;
    FORECAST_MTX = handles.model.getFORECAST_MTX;
    dias_forecast = handles.model.getdias_forecast;
    trn_point = handles.model.gettrn_point;
    numMFs = handles.model.getnumMFs;
    numEpoch = handles.model.getnumEpoch;
    acpe = handles.model.getacpe;
    pf_rendimientos = handles.model.getpf_rendimientos; 
  

    prices = handles.model.getPrices;
     dates = handles.model.getDates;

    benchmark = handles.model.getBenchmark;
    priceslabels = handles.model.getPricesLabels;
    benchmarklabel = handles.model.getBenchmarkLabel;
 
    dataPort = get(handles.PortafoliosPesosReplica,'Data');
    datas = get(handles.uitable_dataseries_assetselection_aprendizaje,'Data');
    datas2 = get(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data');
    datasRow= get(handles.uitable_dataseries_assetselection_aprendizaje,'RowName');
    datasCol= get(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnName');

     pf_precios_sal = handles.model.getpf_precios_sal;
    weight_salida = handles.model.getweight_salida;
    salida_inicio_precio=handles.model.getsalida_inicio_precio; % precio del vector salida precio para calcular el precio del vector y no solo retornos
    str = strcat(datestr(now,'yyyymmddHHMM'),'FIS', 'Index');
    
   save(['C:\MATLAB\PortafolioFis\datafeed_import ',str],'prices','dates','priceslabels','fismat1','TRN_CHECK', 'CHK_CHK', 'TRN_APRENDIZAJE', 'TRN_MTX','CHK_MTX','FORECAST_MTX','dias_forecast','trn_point','numMFs','numEpoch','acpe','pf_rendimientos', 'prices', 'dates', 'benchmark','priceslabels','benchmarklabel','datasRow','datasCol','dataPort','datas','datas2','weight_salida','pf_precios_sal','salida_inicio_precio' );
    
   set(handles.numMFs,'Enable','off');
    set(handles.numEpochs,'Enable','off');
    set(handles.TRN,'Enable','off');
    set(handles.FORECAST,'Enable','off');
    set(handles.axes_tab_1,'Visible','off');
    set(handles.axes_tab_2,'Visible','off');
    set(handles.axes_tab_3,'Visible','off');
 
    set(handles.uitable_dataseries_assetselection_aprendizaje,'Enable', 'off');
    set(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Enable','off');
    set(handles.numMFs,'Enable','off');
    set(handles.numEpochs,'Enable','off');
    set(handles.TRN,'Enable','off');
    set(handles.FORECAST,'Enable','off');
    set(handles.checkbox_ACP,'Enable','off');
    set(handles.button_aprendizajes,'Enable','off');
    set(handles.LoadFis,'Enable','off');
    set(handles.Anfis_Edit,'Enable','off');
    set(handles.SaveFis,'Enable','off');
    set(handles.checkbox_Cabeza,'Enable','off');
    set(handles.Activar_Pestanas,'Enable','on');
 
end

% --- Executes on button press in Anfis_Edit.
function Anfis_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Anfis_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%clear dates 
fuzzy;
anfisedit;

end


% --- Executes on button press in checkbox_Cabeza.
function checkbox_Cabeza_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Cabeza (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_Cabeza

 % val = boolean(get(handles.checkbox_Cabeza,'Value'));
    
          % if val == true
             
          %  end
            
       set(handles.checkbox_Cabeza,'Value',false);     
  tab_handler(1,handles);          
end 


% --- Executes on button press in cab_grupo.
function cab_grupo_Callback(hObject, eventdata, handles)
% hObject    handle to cab_grupo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_text = get(handles.cab_grupo,'String');

if strcmp('Cabeza de Grupo',button_text)
      
               data = get(handles.uitable_importedseries_pricesseries,'Data');
              
               if isempty(data)
        return
    end
    priceslabels = get(handles.uitable_importedseries_pricesseries,'ColumnName');
    if get(handles.checkbox_importedseries_usefirstcolasbenchmark,'Value')
        benchmark = data(:,1);
        prices = data(:,2:end);
        benchmarklabel = priceslabels{1};
        priceslabels(1) = [];
    else
        benchmark = [];
        prices = data;
        benchmarklabel = '';
    end
    dates = get(handles.uitable_importedseries_pricesseries,'RowName');
    if ~isempty(dates)
        dates = datenum(dates,handles.datestringformat);    
    end
    handles.model.importData(prices,benchmark,dates,priceslabels,benchmarklabel)
         [~,~,~,annualized_ret,annualized_rsk] = handles.model.getStatistics(true);  % annualized stats for all assets         
                    TRN_APRENDIZAJE= prices;
                  tt = size(TRN_APRENDIZAJE,2);
                
                
                u = 1;
               
                 for p = (u:tt-1)% renglones, no toma en cuenta la priemera1
                     %if abs(corr(p,j)) > .6
                     
                     for pp = (p+1:tt)
                                    % while pp+1 < tt
                                     %if pp == 88
                                     %    o=corrcoef(TRN_APRENDIZAJE(:,pp),TRN_APRENDIZAJE(:,p));
                                     %end
                       %if pp>tt 
                       % break
                       %end  
                                        %o=corrcoef(TRN_APRENDIZAJE(:,1),TRN_APRENDIZAJE(:,p));
                     o=corrcoef(TRN_APRENDIZAJE(:,pp),TRN_APRENDIZAJE(:,p));
                     
                     yt= o(1,2);
                    if abs((yt)) > .85
                        tt = tt - 1;
                        
                        
                         %data(:,pp) = [0];
                     %detect(p,j)=1;  
                     %handles.model.enableAssetaprendizaje(p,false);
                     %sel = cell2mat(data(:,2));
                     %data(indices(1),2) = {true};
                     %data(p,2) = {false}; 
                     
                     if (annualized_rsk(:,pp)> annualized_rsk(:,p)) 
                        if (annualized_ret(:,pp) > 0 && annualized_ret(:,pp) > annualized_ret(:,p))
                         
                         prices(:,p) = [];
                          priceslabels(p) = [];
                        else
                         prices(:,pp) = [];
                          priceslabels(pp) = [];
                        end
                     else
                      %data(:,pp) = []; 
                      
                      if (annualized_ret(:,p) > 0 && annualized_ret(:,p) > annualized_ret(:,pp))
                         
                         % if isempty(data(:,pp))
                         %      data(:,pp) = [];
                         % end
                          prices(:,pp) = [];
                          priceslabels(pp) = [];
                        else
                         prices(:,p) = [];
                          priceslabels(p) = [];
                      end
                      tt = tt - 1;
                     end
                     %if (tt>p)
                     %tt = tt-1;
                     %end
                    else
                                  % handles.model.enableAssetaprendizaje(p,true);
                                  % data(p,2) = {true};   


                                 %if pp>tt 
                                 %       break
                                 % end
                    
                   % tt = tt - 1;
                    
                    end  

                    
                           

                            if pp>(tt)
                                break
                            end
                     end
                 end
                 data = prices;
                  data=data(:,any(data));
                 set(handles.uitable_importedseries_pricesseries,'Data',data);
                
                 
                % series = [benchmark(:),prices];
                % serieslabels = [benchmarklabel,priceslabels(:)'];
              
        if get(handles.checkbox_importedseries_usefirstcolasbenchmark,'Value')
        % use first column as benchmark index
        %benchmark = data(:,1);
        data = [benchmark prices];
        %[temporal prices(:,p)];
        %benchmarklabel = priceslabels{1};
        %priceslabels(1) = [];
         priceslabels   = [benchmarklabel,priceslabels'];
        else
        % no benchmark
        %benchmark = [];
        data = prices;
        %benchmarklabel = '';
        end
                
                
                
                
               % priceslabels   = [benchmarklabel,priceslabels'];
                 
                 set(handles.uitable_importedseries_pricesseries,'ColumnName',priceslabels);
                set(handles.uitable_importedseries_pricesseries,'Data',data);
              % matrixaprendizaje = handles.model.getPricesaprendizaje;
              set(handles.cab_grupo,'String','Regresar');
       
else
    
    
   %set(handles.cab_grupo,'String','Cabeza de Grupo'); 
   % button_dataimport_datafeed_downloadseries_Callback(hObject, eventdata, handles);
    
    
    
    
    
    
    
         if strcmp(get(handles.uipanel_dataimport_datafeed,'Visible'),'on')
       
            set(handles.cab_grupo,'String','Cabeza de Grupo');
            set(handles.uitable_importedseries_pricesseries,'Data',[]);
            set(handles.uitable_importedseries_pricesseries,'ColumnName',[]);
            pause(0.05);  % give some time to update
            button_dataimport_datafeed_downloadseries_Callback(hObject, eventdata, handles);
            set(handles.button_correlation_accept,'Enable','on'); 
    
         end
        
         
        
          if strcmp(get(handles. uipanel_dataimport_xlsfile,'Visible'),'on')
       
    
            set(handles.cab_grupo,'String','Cabeza de Grupo');
            set(handles.uitable_importedseries_pricesseries,'Data',[]);
            set(handles.uitable_importedseries_pricesseries,'ColumnName',[]);
            pause(0.05); 
           % button_dataimport_datafeed_downloadseries_Callback(hObject, eventdata, handles);
            button_dataimport_excelfile_import_Callback(hObject, eventdata, handles);
            set(handles.button_correlation_accept,'Enable','on'); 
          end
         
          
           if strcmp(get(handles. uipanel_dataimport_workspace,'Visible'),'on')
       
    
    
      set(handles.cab_grupo,'String','Cabeza de Grupo');
            set(handles.uitable_importedseries_pricesseries,'Data',[]);
            set(handles.uitable_importedseries_pricesseries,'ColumnName',[]);
            pause(0.05);  % give some time to update
           button_dataimport_workspace_importdata_Callback(hObject, eventdata, handles);
            set(handles.button_correlation_accept,'Enable','on'); 
  
          end
    
    
    
    
    
    
    
    
end
end


% --- Este boton se decidió quitarlo.
function Correr_Callback(hObject, eventdata, handles)
% hObject    handle to Correr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ii=size(handles.model.getDates,1);
iii=size(handles.model.getTRN_MTX,1);
iiii=size(handles.model.getCHK_MTX,1);
str = strcat('Total.',' ',num2str(ii));
        set(handles.TotalSalida,'String',str);  
str = strcat('TRN.',' ',num2str(iii));
        set(handles.TRNA,'String',str);  
str = strcat('CHK.',' ',num2str(iiii));
        set(handles.CHKSALIDA,'String',str);  
        
acpi = handles.model.getacpe;

 %val = boolean(get(handles.TotalSalida,'Value'));
              if acpi == true
               set(handles.ACP_ENTRADA,'Value',1);
              else
                set(handles.ACP_ENTRADA,'Value',0);  
              end
        
        

set(handles.uitable_dataseries_salida,'ColumnEditable',get(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnEditable'));
 
  d= get(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnFormat'); 
  %d(3,1) = ['logical'];
  %d2 = ['char'  'logical' 'logical' 'logical'];
%set(handles.uitable_dataseries_salida,'ColumnFormat',get(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnFormat'));
set(handles.uitable_dataseries_salida,'ColumnFormat',{'char','logical','logical','logical'});
 set(handles.uitable_dataseries_salida,'ColumnEditable',[false,true,false,false]);
 
 set(handles.uitable_dataseries_salida,'RowName',[]);
        % set column headers
 set(handles.uitable_dataseries_salida,'ColumnName',{'Nombre del activo','Seleccionar','Aprendizaje', 'Salida'});
%set(handles.uitable_dataseries_salida,'RowName',get(handles.uitable_dataseries_assetselection_aprendizaje,'RowName'));
%set(handles.uitable_dataseries_salida,'ColumnName',get(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnName'));
%set(handles.uitable_dataseries_salida,'Data',get(handles.uitable_dataseries_assetselection_aprendizaje,'Data'));
 % datas = [datas ; 'Portfolio Select',num2cell(true) , metricaportafolio(2,2),metricaportafolio(1,2)  ]; 
datass = get(handles.uitable_dataseries_assetselection_aprendizaje,'Data');   
datasss = get(handles.uitable_dataseries_assetselection_aprendizaje_sal,'Data'); %ACTIVARLA DESDE APRENDIZAJE O LOAD
datass = [datass(:,1:2) datass(:,2) datasss(:,2)];
datass(:,2) =  num2cell(false);
%encabezados = get(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnName');
%encabezados = [encabezados(1:2);'Aprendizaje';'Salida'];
%c= get(handles.uitable_dataseries_assetselection_aprendizaje,'ColumnEditable');    
%c=[0 1 0 0];


set(handles.uitable_dataseries_salida,'Data',datass);

%set(handles.uitable_dataseries_salida,'ColumnName',encabezados);

 




bench = handles.model.getBenchmarkLabel;
etiqueta = handles.model.getPricesLabels;


 
% Visualize portfolio performance, compare to benchmark
            axes(handles.grafica_salida);
            set(handles.grafica_salida,'Visible','on');
            hold('off')
            dates = handles.model.getDates;
            prices = handles.model.getPrices;
            hh=dates(2:end);
            prices_rendimientos = tick2ret(prices,dates,'Simple');
           precios = ret2price(prices_rendimientos, prices(1,:),[],0,'Periodic'); %, dates(2:end),0,'Simple');
           
            % precios = ret2price(prices_rendimientos,81.3400, dates(1:end),'Periodic');
           % precios = ret2price(prices_rendimientos,81.3400,dates(2:end),0,'Continous'); 
           %pf_prices = prices*weights;
            pf_prices = prices(:,2);
            %pf_prices = 100*pf_prices/abs(pf_prices(1));  % normalize
            %if pf_prices(1) < 0
            %    pf_prices = pf_prices + 200;   % shift up if first val = -100
            %end
            legend_str = 'Selected Portfolio';
            if ~isempty(dates)
                plot(dates,pf_prices);
                axis('tight');
                datetick('x','keeplimits');
            else
                plot(pf_prices);
            end
            grid('on');
            box('off');
            ylabel('Relative Performance [%]');
            hold('on'); %Borra lo anterior
            benchmark = handles.model.getBenchmark;
            if ~isempty(benchmark)
                legend_str = {legend_str,handles.model.getBenchmarkLabel};
                benchmark = 100*benchmark/benchmark(1);   % normalize
                if ~isempty(dates)
                    plot(dates,benchmark,'r');
                    axis('tight');
                    datetick('x','keeplimits');
                else
                    plot(benchmark,'r');
                   
                end
            end
            h = legend(legend_str,'Location','NorthWest');
            set(h,'UIContextMenu',[]);
            set(h,'HitTest','off');
            set(h,'Box','off')
            el = get(h,'Children');
            for j = 1:length(el)  %change text backgrounds to white
                if strcmp(get(el(j),'Type'),'text')
                    set(el(j),'BackgroundColor',[1,1,1]);
                end
            end
            % save legend handle
            handles.grafica_salida = h;
            guidata(hObject, handles);
%cla(handles.grafica_salida);
        %h = zoom;
        %set(h,'Motion','horizontal','Enable','on');
%clf(handles.grafica_salida);
%items = get(handles.grafica_salida, 'Children');
%delete(items(end));
%handles.grafica_salida = clf;
%zoom on;
%zoom off; % hacer otro botón


 plotobjects = get(handles.grafica_salida,'Children');
   
        for i = 1:length(plotobjects)
            delete(plotobjects(i));
        end

end


function uitable_dataseries_salida_CellEditCallback(hObject, eventdata, handles)
% hObject    ESATAMOS ESPERANDO CORREGIR PARA CUANDO LLEGUEN 4 ACCIONES DEJAR ACP AUTOMATICO)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

    % Update portfolio component selection
 indices = eventdata.Indices;
    state=   eventdata.NewData;
data = get(handles.uitable_dataseries_salida,'Data');
axes(handles.grafica_salida);
%num2cell(true)
guidata(handles.figure, handles);

%limpiamos la tabla siguiente
set(handles.TotalSalida,'Value',0);  
set(handles.CHKSALIDA,'Value',0);  
set(handles.TRNA,'Value',0); 
set(handles.ErrorSalida,'Value',0); 




sel = cell2mat(data(:,2));






if (sum(sel) == 3) && (state == true)  % aqui entraria el acp
   % set(handles.checkbox_ACP,'Value',1);  % Se activa automaticamente el ACP
        data(indices(1),2) = {false};
        set(handles.uitable_dataseries_salida,'Data',data);
        
       
else
    if (sum(sel) == 0) && (state == false)  % para que no quede vacio
     data(indices(1),2) = {true};
     set(handles.uitable_dataseries_salida,'Data',data);
    else 
    if  (state == false)
        data(indices(1),2) = {false};
        set(handles.uitable_dataseries_salida,'Data',data);
    else
        data(indices(1),2) = {true};
        set(handles.uitable_dataseries_salida,'Data',data);
       
       

    end

    end



            legend_str = '';

           % axes(handles.axes_results_efficientfrontier);
           %axes(handles.grafica_salida);
           % set(handles.grafica_salida,'Visible','on');
           %cla(handles.grafica_salida);
           hold('off');
            
            
            % plotobjects = get(handles.grafica_salida,'Children');
   
        %for i = 1:length(plotobjects)
        %    delete(plotobjects(i));
        %end
            
            
            
            
           % clf(handles.grafica_salida,'reset')
           % guidata(hObject, handles); 
          % return;
            dates = handles.model.getDates;
            prices = handles.model.getPrices;
            %hh=dates(2:end);
            prices_rendimientos = tick2ret(prices,dates,'Simple');
             % get portfolio
           % weights = handles.model.pf_weights(pf_number,:);
           % weights = weights(:);   % use column vectors
           % pf_pices_porfolio = handles.model.prices(:,this.assetselection)*weights;  % portfolio prices
          
           precios = ret2price(prices_rendimientos, prices(1,:),[],0,'Periodic'); %, dates(2:end),0,'Simple');
          %pf_pices_porfolio = ret2price(handles.model.getpf_rendimientos, 
          
           pf_pices_porfolio=handles.model.getpf_precios_sal;
          % d=size(data,1);
           % yo='r';
           
            val = boolean(get(handles.Ren_Salida,'Value'));
            
           
            for j=1:size(data,1)
            %precios = ret2price(prices_rendimientos, prices(j,:),[],0,'Periodic'); %, dates(2:end),0,'Simple');
           sel = cell2mat(data(:,2));
            TP = strcmp(data(end,1),'Portfolio Select'); % Solo si se encuentra el indice no al inicio de matriz
          TPFIN = strcmp(data(end-1,1),'Portfolio Select'); % Solo si se encuentra el indice no al inicio de matriz
         
            %  TIND = strcmp(data(end,1),'Portafolio Select'); % Solo si se encuentra el indice no al inicio de matriz
            
            %if  rem(j,2)==0
            %    yo='r'; %disp('El número es Par')
            %else
            %     yo='g'; %disp('El número es Impar')
            %end

          if (j==1)
              yo = 'y';
          end
          if (j==2)
              yo = 'm';
          end
              if (j==3)
              yo = 'c';
              end
            if (j==4)
              yo = 'r';
            end
              
             if (j==5)
              yo = 'g';
             end
              
              if (j==6)
              yo = 'b';
              end
              
               if (j==7)
              yo = 'w';
               end
              
               if (j==8)
              yo = 'k';
               end
              
                if (j>8)
              yo = 'r';
               end
               
            if ((sel(j) == 1)) % && TP == 0)
             if (j == size(data,1)-1 && TPFIN == 1)
                 % PORTFOLIO
                  pf_prices = pf_pices_porfolio;
                   else
                 if (j == size(data,1) && TP == 1)
                 %PORTFOLIO
                 pf_prices = pf_pices_porfolio;
                 else
                     if (j == size(data,1) && TP == 0)
                         %INDICE
                         pf_prices =handles.model.getBenchmark;
                     else
                          pf_prices = prices(:,j);
                     end
                 end
                 % sig
             end 
                % pf_prices = prices(:,j);
            
           
            legend_str = {char(data(j,1)),char(legend_str)};
           %pf_prices = prices(:,indices(1));
           
           %legend_str = {legend_str,data(j,1)};
           
            %pf_rendimientos = tick2ret(pf_prices,dates,'Simple');
           %legend_str = data(j,1); % 'Selected Portfolio';
           
           
              if val == true
                  
                  pf_prices = tick2ret(pf_prices,dates,'Simple');
                  %dates= dates(1:end-1);
              end
           
           
           
           
            if ~isempty(dates)
                if val == true
                  
                 plot(dates(1:end-1),pf_prices,yo);
  
                else
                   plot(dates,pf_prices,yo); 
                end
                %plot(dates(1:end-1),pf_prices,yo);
                axis('tight');
                datetick('x','keeplimits');
            else
                plot(pf_prices,'r');
            end
            grid('on');
            box('off');
            if val == false
          
                 ylabel('Precios');
            else
                ylabel('Rendimiento [%]');
            end
            hold('on'); %Borra lo anterior con off
        
           
           end
           end
           %yo='g';
            % if val == true
                  
                 
            %      dates= dates(1:end-1);
            %  end
     % save legend handle
  %legend_str = '';
  %for j=1:size(data,1)
 %legend_str = {char(legend_str),char(data(j,1))};
%  end
  %str = strcat('Maximo para TRNA: ', yy); 
  %legend_str = strcat (data(1,1), data(2,1));
            h = legend(legend_str,'Location','NorthWest');
            set(h,'UIContextMenu',[]);
            set(h,'HitTest','off');
            set(h,'Box','off')
            el = get(h,'Children');
            for p = 1:length(el)  %change text backgrounds to white
                if strcmp(get(el(p),'Type'),'text')
                    set(el(p),'BackgroundColor',[1,1,1]);
                end
            end
            handles.grafica_salida = h;
            guidata(hObject, handles); 
          
           





end





%handles.model.enableAssetaprendizaje(indices(1),state);

end

function TRNA_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Cabeza (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%limpia el lado la tabla contraria el bool
    datass = get(handles.uitable_dataseries_salida,'Data');   
    datass(:,2) =  num2cell(false);
    set(handles.uitable_dataseries_salida,'Data',datass);
    set(handles.TotalSalida,'Value',0);  
    set(handles.CHKSALIDA,'Value',0);  
    set(handles.TRNA,'Value',1); 
    set(handles.ErrorSalida,'Value',0);  
    %limpiamos la otra tabla para que no aparezca seleccionada alguna
    %data = get(handles.uitable_dataseries_salida,'Data'); %ACTIVARLA DESDE APRENDIZAJE O LOAD
    %data(:,2) =  num2cell(false);
    %set(handles.uitable_dataseries_salida,'Data',data);
            %val = boolean(get(handles.TotalSalida,'Value'));
                 % if val == true
               %    set(handles.checkbox_ACP,'Value',0);
               % end

            guidata(handles.figure, handles);
            axes(handles.grafica_salida);
            legend_str = '';
             hold('off');
            
% Se carga datos
             dias_forecast = handles.model.getdias_forecast;
            trn_point = handles.model.gettrn_point;
            dates = handles.model.getDates;
            dates= dates(dias_forecast:trn_point+ dias_forecast);
            TRN_MTX = handles.model.getTRN_MTX;

% Se revisa que sea Rendimientos
            val = boolean(get(handles.Ren_Salida,'Value'));
              if val == true
                dates= dates(1:end-1);
              else
                 TRN_MTX =ret2price(TRN_MTX, handles.model.getsalida_inicio_precio,[],0,'Periodic');
               end
         
         
              pf_prices= TRN_MTX;
              temporal= pf_prices;

                data1(1,1) = mean(pf_prices); % mean
                  data1(2,1)= std(pf_prices); % std
                  data1(3,1)=  skewness(pf_prices);
                  data1(4,1) = kurtosis(pf_prices);

         
            if ~isempty(dates)
                plot(dates,pf_prices,'g');
                axis('tight');
                datetick('x','keeplimits');
            else
                plot(pf_prices,'r');
            end
            grid('on');
            box('off');
            if val == false
          
                 ylabel('Precios');
            else
                ylabel('Rendimiento [%]');
            end
            hold('on'); %Borra lo anterior con off
        


             fismat1 = handles.model.getfismat; 
           TRN_CHECK = handles.model.getTRN_CHECK; 
           CHK_CHK = handles.model.getCHK_CHK;
           
           anfis_TRN_CHECK=evalfis(TRN_CHECK,fismat1);
           pf_prices = anfis_TRN_CHECK; % [anfis_TRN_CHECK ; anfis_TRN_CHECK2]; 
          
             if val == false
          
                  pf_prices =ret2price(pf_prices,handles.model.getsalida_inicio_precio,[],0,'Periodic');
            end
            
           
           legend_str = {'Real','Pronostrico'};
           
            data1(1,2) = mean(pf_prices); % mean
              data1(2,2)= std(pf_prices); % std
              data1(3,2)=  skewness(pf_prices);
              data1(4,2) = kurtosis(pf_prices);
           
           if ~isempty(dates)
                plot(dates,pf_prices,'r');
                axis('tight');
                datetick('x','keeplimits');
            else
                plot(pf_prices,'r');
            end
            grid('on');
            box('off');
            if val == false
          
                 ylabel('Precios');
            else
                ylabel('Rendimiento [%]');
            end
            hold('on'); %Borra lo anterior con off
          
            
            
            
          
            h = legend(legend_str,'Location','NorthWest');
            set(h,'UIContextMenu',[]);
            set(h,'HitTest','off');
            set(h,'Box','off')
            el = get(h,'Children');
            for p = 1:length(el)  %change text backgrounds to white
                if strcmp(get(el(p),'Type'),'text')
                    set(el(p),'BackgroundColor',[1,1,1]);
                end
            end
            handles.grafica_salida = h;
            guidata(hObject, handles); 
          
           
set(handles.SalidaResultados,'ColumnFormat',{'char','char'});
set(handles.SalidaResultados,'ColumnEditable',[false,false]);
 datesstr = cellstr(datestr(dates,handles.datestringformat));
  set(handles.SalidaResultados,'RowName',datesstr);
 

  datesstr = cellstr(datestr(dates,handles.datestringformat));
  set(handles.SalidaResultados,'RowName',datesstr);

  data = [temporal , pf_prices, abs(temporal - pf_prices)];
 set(handles.SalidaResultados,'Data',data);         
   set(handles.SalidaResultados,'ColumnName',{'Real','Forecast','Error Abs'});

 set(handles.SalidaResultados,'Data',data);         

 
set(handles.MetricaSalida,'Data',data1); 
set(handles.MetricaSalida,'RowName',{'Mean','STD','Skewness','Kurtosis'});
set(handles.MetricaSalida,'ColumnName',{'Real','Forecast'});
end 
% --- Executes on button press in zoomin.
function zoomin_Callback(hObject, eventdata, handles)
% hObject    handle to zoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.grafica_salida);
zoom on;
end






% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end
