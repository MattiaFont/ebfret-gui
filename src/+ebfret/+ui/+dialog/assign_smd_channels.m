function channels = assign_smd_channels(labels)
    % global status;
    status = 0;
    self.dialog = dialog('name', 'Assign Channels', ...
                         'color', [0.95 0.95 0.95], ...
                         'units', 'pixels', ...
                         'CloseRequestFcn', @(varargin) resume(0));
    set(self.dialog, ...
        'DefaultUIPanelBackGroundColor', [0.95 0.95 0.95], ...
        'DefaultUIControlUnits', 'normalized');


    % element sizes (pixels)
    row_height = 18;
    edit_width = 180;
    label_width = 60;

    % vertical and horizontal padding (pixels)
    pad_width = 6;
    pad_height = 10;

    % dialog height and width
    num_rows = 4;
    dialog_height = (num_rows+1) * row_height + (num_rows+2) * pad_height;
    dialog_width = 3 * pad_width + label_width + edit_width;

    % get normalized units
    rh = row_height / dialog_height;
    ew = edit_width / dialog_width;
    lw = label_width / dialog_width;

    ph = pad_height / dialog_height;
    pw = pad_width / dialog_width;

    % adjust dialog size
    rect = get(self.dialog, 'position');
    set(self.dialog, 'position', [rect(1) rect(2) dialog_width dialog_height]);

    % ui elements: 6 rows, 2 columns
    self.methodPopupLabel ...
        = uicontrol(self.dialog, ...
            'style', 'text', ...
            'backgroundcolor', [0.95 0.95 0.95], ...
            'string', 'Signal Type', ...
            'horizontalalignment', 'left', ...
            'position', [pw 1-1*(rh+ph) lw rh]);
    self.methodPopup ...
        = uicontrol(self.dialog, ...
            'style', 'popup', ...
            'string', 'Donor-Acceptor|FRET', ...
            'callback', @(varargin) methodPopupCallback(), ...
            'position', [lw+2*pw 1-1*(rh+ph) ew rh]);
    self.donorPopupLabel ...
        = uicontrol(self.dialog, ...
            'style', 'text', ...
            'backgroundcolor', [0.95 0.95 0.95], ...
            'string', 'Donor', ...
            'horizontalalignment', 'left', ...
            'position', [pw 1-2*(rh+ph) lw rh]);
    self.donorPopup ...
        = uicontrol(self.dialog, ...
            'style', 'popup', ...
            'string', ebfret.join('|', labels), ...
            'callback', @(varargin) methodPopupCallback(), ...
            'position', [lw+2*pw 1-2*(rh+ph) ew rh]);
    self.acceptorPopupLabel ...
        = uicontrol(self.dialog, ...
            'style', 'text', ...
            'backgroundcolor', [0.95 0.95 0.95], ...
            'string', 'Acceptor', ...
            'horizontalalignment', 'left', ...
            'position', [pw 1-3*(rh+ph) lw rh]);
    self.acceptorPopup ...
        = uicontrol(self.dialog, ...
            'style', 'popup', ...
            'string', ebfret.join('|', labels), ...
            'callback', @(varargin) methodPopupCallback(), ...
            'position', [lw+2*pw 1-3*(rh+ph) ew rh]);
    self.fretPopupLabel ...
        = uicontrol(self.dialog, ...
            'style', 'text', ...
            'backgroundcolor', [0.95 0.95 0.95], ...
            'string', 'FRET', ...
            'horizontalalignment', 'left', ...
            'position', [pw 1-4*(rh+ph) lw rh]);
    self.fretPopup ...
        = uicontrol(self.dialog, ...
            'style', 'popup', ...
            'string', ebfret.join('|', labels), ...
            'callback', @(varargin) methodPopupCallback(), ...
            'position', [lw+2*pw 1-4*(rh+ph) ew rh]);
    self.okButton ...
        = uicontrol(self.dialog, ...
            'style', 'pushbutton', ...
            'string', 'Ok', ...
            'position', [pw ph 0.5-1.5*pw rh], ...
            'callback', @(varargin) resume(1));
    self.cancelButton ...
        = uicontrol(self.dialog, ...
            'style', 'pushbutton', ...
            'string', 'Cancel', ...
            'position', [0.5+0.5*pw ph 0.5-1.5*pw rh], ...
            'callback', @(varargin) resume(0));

    function methodPopupCallback(value)
        if nargin < 1
            value = get(self.methodPopup, 'value');
        end
        switch value 
            case 1
                set(self.donorPopup, 'enable', 'on');
                set(self.acceptorPopup, 'enable', 'on');
                set(self.fretPopup, 'enable', 'off');
            case 2
                set(self.donorPopup, 'enable', 'off');
                set(self.acceptorPopup, 'enable', 'off');
                set(self.fretPopup, 'enable', 'on');
        end
    end

    function resume(int)
        status = int;
        uiresume();
    end

    methodPopupCallback(1);
    uiwait(self.dialog);
    if status 
        switch get(self.methodPopup, 'value')
        case 1
            channels.donor = get(self.donorPopup, 'value');
            channels.acceptor = get(self.acceptorPopup, 'value');
            channels.fret = nan;
        case 2
            channels.donor = nan;
            channels.acceptor = nan;
            channels.fret = get(self.fretPopup, 'value');
        end
    else
        channels.donor = nan;
        channels.acceptor = nan;
        channels.fret = nan;
    end
    delete(self.dialog);
end