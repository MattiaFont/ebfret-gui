classdef MainWindow < hgsetget
    properties
        % holds references to ui elements contained in main window
        handles 
        % stores values of control elements
        controls
        % holds time series data for currently loaded dataset
        series 
        % holds analysis results for currently loaded dataset
        analysis
        % holds plot data
        plots
    end
    methods
        function self = MainWindow(series, analysis, varargin)
            self.handles.mainWindow ...
                = figure('name', 'ebFRET', ...
                         'units','pixels', ...
                         'position', [200 200 1000 700], ...
                         'color', [0.95 0.95 0.95], ...
                         'menubar', 'none', ... 
                         'numbertitle','off', ...
                         'resize','on');

            % set some defaults
            set(self.handles.mainWindow, ...
                'DefaultUIPanelBackGroundColor', [0.95 0.95 0.95], ...
                'DefaultUIControlUnits', 'normalized', ...
                'DefaultAxesLooseInset', [0.00, 0, 0, 0], ... 
                'DefaultAxesUnits', 'normalized');

            % horizontal and vertical padding and button height (normalized units)
            pos = getpixelposition(self.handles.mainWindow);
            hp = 4 / pos(3);
            vp = 4 / pos(4);
            bh = 40 / pos(4);

            % plot panels: time series and ensemble
            self.handles.seriesPanel ...
                = ebfret.ui.PlotPanel(...
                    'parent', self.handles.mainWindow, ...
                    'title', 'Time Series', ...
                    'position', [hp, 0.40+2*vp+2*bh, 1-2*hp, 0.60-3*vp-2*bh], ...
                    'axes', {'time', [hp, 0.5+4*vp, 1-2*hp, 0.5-6*vp], ...
                             'obs', [4*hp, 2*vp, 0.25-2*hp 0.5-2*vp], ...
                             'mean', [0.25+3*hp, 2*vp, 0.25-2*hp, 0.5-2*vp], ...
                             'noise', [0.50+2*hp 2*vp, 0.25-2*hp, 0.5-2*vp], ...
                             'dwell', [0.75+hp, 2*vp, 0.25-2*hp, 0.5-2*vp]});
            self.handles.ensemblePanel ...
                = ebfret.ui.PlotPanel(...
                    'parent', self.handles.mainWindow, ...
                    'title', 'Ensemble', ...
                    'position', [hp, 2*vp+3*bh, 1-2*hp, 0.40-3*vp-2*bh], ...
                    'axes', {'obs', [4*hp, 2*vp, 0.25-2*hp 1-4*vp], ...
                             'mean', [0.25+3*hp, 2*vp, 0.25-2*hp, 1-4*vp], ...
                             'noise', [0.50+2*hp 2*vp, 0.25-2*hp, 1-4*vp], ...
                             'dwell', [0.75+hp, 2*vp, 0.25-2*hp, 1-4*vp]});

            % sliders for time series and ensemble pots
            self.handles.seriesControl ...
                = ebfret.ui.IndexControl(...
                    'parent', self.handles.mainWindow, ...
                    'callback', @(v) self.set_control('series', struct('value', v)), ...
                    'position', [hp, 0.40+vp+bh, 0.7-hp, bh]);
            self.handles.ensembleControl ...
                = ebfret.ui.IndexControl(...
                    'parent', self.handles.mainWindow, ...
                    'callback', @(v) self.set_control('ensemble', struct('value', v)) , ...
                    'position', [hp, vp+2*bh, 1-2*hp, bh]);

            % controls series cropping
            self.handles.clipPanel ...
                = uipanel(self.handles.mainWindow, ...
                          'position', [0.7+hp, 0.40+vp+bh, 0.3-2*hp, bh]);
            self.handles.clipMinLabel ...
                = uicontrol(self.handles.clipPanel, ...
                            'style', 'text', ...
                            'string', 'Min', ...
                            'position', [0+hp 0.2+vp/bh 0.15-hp 0.6-2*vp/bh]);
            self.handles.clipMinEdit ...
                = uicontrol(self.handles.clipPanel, ...
                            'style', 'edit', ...
                            'backGroundColor', [1 1 1], ...
                            'callback', @(source, event) ...
                                self.set_control(...
                                    'clip', struct('min', self.get_ui('clip_min'))), ...
                            'position', [0.15+hp vp/bh 0.2-hp 1-2*vp/bh]);
            self.handles.clipMaxLabel ...
                = uicontrol(self.handles.clipPanel, ...
                            'style', 'text', ...
                            'string', 'Max', ...
                            'position', [0.35+hp 0.2+vp/bh 0.15-hp 0.6-2*vp/bh]);
            self.handles.clipMaxEdit ...
                = uicontrol(self.handles.clipPanel, ...
                            'style', 'edit', ...
                            'backGroundColor', [1 1 1], ...
                            'callback', @(source, event) ...
                                self.set_control(...
                                    'clip', struct('max', self.get_ui('clip_max'))), ...
                            'position', [0.5+hp vp/bh 0.2-2*hp 1-2*vp/bh]);
            self.handles.includeCheck ...
                = uicontrol(self.handles.clipPanel, ...
                            'style', 'checkbox', ...
                            'string', 'Exclude', ...
                            'position', [0.75+hp vp/bh 0.25-hp 1-2*vp/bh]);
                            % 'callback', @(source, event) ...
                            %     self.set_control('min_clip', ...
                            %                      self.get_ui('min_clip')), ...

            % controls: number of states
            self.handles.statesPanel ...
                = uipanel(self.handles.mainWindow, ...
                           'title', 'States', ...
                           'position', [hp, bh+vp, 0.20-hp, bh]);
            self.handles.minStatesLabel ...
                = uicontrol(self.handles.statesPanel, ...
                            'style', 'text', ...
                            'string', 'Min', ...
                            'position', [0 0.2 0.2 0.6]);
            self.handles.minStatesEdit ...
                = uicontrol(self.handles.statesPanel, ...
                            'style', 'edit', ...
                            'callback', @(source, event) ...
                                self.set_control('min_states', ...
                                                 self.get_ui('min_states')), ...
                            'backGroundColor', [1 1 1], ...
                            'position', [0.2 0 0.3 1]);
            self.handles.maxStatesLabel ...
                = uicontrol(self.handles.statesPanel, ...
                            'style', 'text', ...
                            'string', 'Max', ...
                            'position', [0.5 0.2 0.2 0.6]);
            self.handles.maxStatesEdit ...
                = uicontrol(self.handles.statesPanel, ...
                            'style', 'edit', ...
                            'callback', @(source, event) ...
                                self.set_control('max_states', ...
                                                 self.get_ui('max_states')), ...
                            'backGroundColor', [1 1 1], ...
                            'position', [0.7 0 0.3 1]);
            % align(get(self.handles.statesPanel, 'children'), ...
            %       'horizontalalignment', 'distribute', ...
            %       'verticalalignment', 'middle');

            % controls: restarts
            self.handles.restartsPanel ...
                = uipanel(self.handles.mainWindow, ...
                           'title', 'Restarts', ...
                           'position', [0.20+hp, bh+vp, 0.25-hp, bh]);
            self.handles.initRestartsLabel ...
                = uicontrol(self.handles.restartsPanel, ...
                            'style', 'text', ...
                            'string', 'Init', ...
                            'position', [0 0.2 0.1 0.6]);
            self.handles.initRestartsEdit ...
                = uicontrol(self.handles.restartsPanel, ...
                            'style', 'edit', ...
                            'callback', @(source, event) ...
                                self.set_control('init_restarts', ...
                                                 self.get_ui('init_restarts')), ...
                            'backGroundColor', [1 1 1], ...
                            'position', [0.1 0 0.2 1]);
            self.handles.allRestartsLabel ...
                = uicontrol(self.handles.restartsPanel, ...
                            'style', 'text', ...
                            'string', 'All', ...
                            'position', [0.35 0.2 0.1 0.6]);
            self.handles.allRestartsEdit ...
                = uicontrol(self.handles.restartsPanel, ...
                            'style', 'edit', ...
                            'callback', @(source, event) ...
                                self.set_control('all_restarts', ...
                                                 self.get_ui('all_restarts')), ...
                            'backGroundColor', [1 1 1], ...
                            'position', [0.45 0 0.2 1]);
            self.handles.GmmRestartsCheck ...
                = uicontrol(self.handles.restartsPanel, ...
                            'style', 'checkbox', ...
                            'string', 'Fit GMM', ...
                            'callback', @(source, event) ...
                                self.set_control('gmm_restarts', ...
                                                 self.get_ui('gmm_restarts')), ...
                            'backGroundColor', [1 1 1], ...
                            'position', [0.7 0 0.3 1]);
            align(get(self.handles.restartsPanel, 'children'), ...
                  'horizontalalignment', 'distribute', ...
                  'verticalalignment', 'middle');

            % controls: analysis
            self.handles.analysisPanel ...
                = uipanel(self.handles.mainWindow, ...
                           'title', 'Analysis', ...
                           'position', [0.45+hp, bh+vp, 0.55-2*hp, bh]);
            self.handles.analysisStatesLabel ...
                = uicontrol(self.handles.analysisPanel, ...
                            'style', 'text', ...
                            'string', 'States', ...
                            'position', [0 0.2 0.08 0.6]);
            self.handles.analysisPopup ...
                = uicontrol(self.handles.analysisPanel, ...
                            'style', 'popup', ...
                            'string', 'All|Current', ...
                            'callback', ...
                                @(source, event) ...
                                self.set_control('run_all', ...
                                                 self.get_ui('run_all')), ...
                            'position', [0.08 0.1 0.17 0.8]);
            self.handles.analysisPrecisionLabel ...
                = uicontrol(self.handles.analysisPanel, ...
                            'style', 'text', ...
                            'string', 'Precision', ...
                            'position', [0.27 0.2 0.08 0.6]);
            self.handles.analysisPrecisionEdit ...
                = uicontrol(self.handles.analysisPanel, ...
                            'style', 'edit', ...
                            'callback', ...
                                @(source, event) ...
                                    self.set_control('run_precision', ...
                                                     self.get_ui('run_precision')), ...
                            'backGroundColor', [1 1 1], ...
                            'position', [0.35 0.0 0.12 1]);
            self.handles.analysisRunButton ...
                = uicontrol(self.handles.analysisPanel, ...
                            'style', 'pushbutton', ...
                            'string', 'Run', ...
                            'callback', ...
                                @(source, event) ...
                                    self.analysisRunStopButtonCallBack(source, event), ...
                            'min', 0, 'max', 1, ...
                            'position', [0.50 0.0 0.15 1.0]);
            self.handles.analysisStopButton ...
                = uicontrol(self.handles.analysisPanel, ...
                            'style', 'pushbutton', ...
                            'string', 'Stop', ...
                            'callback', ...
                                @(source, event) ...
                                    self.analysisRunStopButtonCallBack(source, event), ...
                            'position', [0.675 0.0 0.15 1.0]);
            self.handles.analysisResetButton ...
                = uicontrol(self.handles.analysisPanel, ...
                            'style', 'pushbutton', ...
                            'string', 'Reset', ...
                            'callback', ...
                                 @(source, event) ...
                                    analysisResetButtonCallBack(self, source, event), ...
                            'position', [0.85 0.0 0.15 1.0]);

            % self.handles.GmmRestartsCheck ...
            %     = uicontrol(self.handles.restartsPanel, ...
            %                 'style', 'text', ...
            %                 'string', 'fit GMM', ...
            %                 'position', [0.7 0.2 0.20 0.6]);

            self.handles.statusPanel ...
                = uicontrol(self.handles.mainWindow, ...
                           'style', 'listbox', ...
                           'background', [1 1 1], ...
                           'horizontalalignment', 'left', ...
                           'enable', 'off', ...
                           'position', [hp, vp, 1-2*hp, bh]);


            % file menu
            self.handles.menu.file ...
                = uimenu(self.handles.mainWindow, 'label', 'File');
            self.handles.menu.load ...
                = uimenu(self.handles.menu.file, 'label', 'Load');
            self.handles.menu.save ...
                = uimenu(self.handles.menu.file, 'label', 'Save');
            % self.handles.menu.saveAs ...
            %     = uimenu(self.handles.menu.file, 'label', 'Save As');
            % self.handles.menu.export ...
            %     = uimenu(self.handles.menu.file, 'label', 'Export');
            self.handles.menu.exit ...
                = uimenu(self.handles.menu.file, 'label', 'Exit');

            % file menu callbacks
            set(self.handles.menu.load, 'callback', ...
                @(source, event) load_data(self));
            set(self.handles.menu.save, 'callback', ...
                @(source, event) save_data(self));
            set(self.handles.menu.exit, 'callback', ...
                @(source, event) close(self));

            % analysis menu
            self.handles.menu.analysis ...
                = uimenu(self.handles.mainWindow, ...
                         'label', 'Analysis');
                self.handles.menu.removeBleaching ...
                    = uimenu(self.handles.menu.analysis, ...
                             'callback', ...
                                @(source, event) ...
                                    self.remove_bleaching(), ...
                             'label', 'Remove Photo-bleaching');
                self.handles.menu.clipOutliers ...
                    = uimenu(self.handles.menu.analysis, ...
                             'callback', ...
                                @(source, event) ...
                                    self.clip_outliers(), ...
                             'label', 'Clip Outliers');
                % self.handles.menu.preprocessing ...
                %     = uimenu(self.handles.menu.analysis, ...
                %              'label', 'Pre-Processing');
                % self.handles.menu.prior ...
                %     = uimenu(self.handles.menu.analysis, ...
                %              'label', 'Edit Prior');
                % self.handles.menu.posterior ...
                %     = uimenu(self.handles.menu.analysis, ...
                %              'label', 'Initialize Posterior');
            % self.handles.menu.vbayes ...
            %     = uimenu(self.handles.menu.analysis, ...
            %              'label', 'Run Variational Bayes (vbFRET)');
            % self.handles.menu.ebayes ...
            %     = uimenu(self.handles.menu.analysis, ...
            %              'label', 'Run Empirical Bayes (ebFRET)');

            % plot menu
            self.handles.menu.plot ...
                = uimenu(self.handles.mainWindow, 'label', 'Plot');

            % initialize empty data and analysis fields
            self.series = struct([]); 
            self.analysis = struct([]); 

            % set default axes properties
            default_props.Box = 'on';
            default_props.NextPlot = 'add';
            props = struct('time', default_props, ...
                           'obs', default_props, ...
                           'mean', default_props, ...
                           'noise', default_props, ...
                           'dwell', default_props);

            % remove y tick labels on all but time axis
            fields = {'obs', 'mean', 'noise', 'dwell'};
            for f = 1:length(fields)
                props.(fields{f}).YTickLabel = {};
            end

            % set axes properties
            self.handles.seriesPanel.set_props(props);
            self.handles.ensemblePanel.set_props(rmfield(props, 'time'));

            % set initial analysis and time series
            self.set_control(...
                'series', struct('min', 0, 'max', 0, 'value', 0), ...
                'ensemble', struct('min', 2, 'max', 6, 'value', 2), ...
                'refresh', struct('ensemble', 10, 'series', 1), ...
                'min_states', 2, ...
                'max_states', 6, ...
                'init_restarts', 5, ...
                'all_restarts', 0, ...
                'gmm_restarts', 0, ...
                'run_analysis', false, ...
                'run_all', true, ...
                'run_precision', 1e-5, ...
                'scale_plots', true);

            % set default time series plot colors
            self.controls.colors.obs = [0.4, 0.4, 0.4];
            self.controls.colors.viterbi = [0.66, 0.33, 0.33];
        end
%         refresh_series(self, n);
%         refresh_ensemble(self, a);
%         load_data(self);
%         save_data(self);
%          reset_analysis(self, num_states);
        function analysisResetButtonCallBack(self, source, event)
            self.reset_analysis();
            self.refresh('ensemble', 'series');
        end

        function analysisRunStopButtonCallBack(self, source, event)
            switch source
                case self.handles.analysisRunButton
                    self.set_control('run_analysis', 1);
                case self.handles.analysisStopButton
                    self.set_control('run_analysis', 0);
            end
        end
    end
end
