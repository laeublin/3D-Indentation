% Please note that this file plots the indentation curve without correcting
% for the system's internal stiffness. The resulting apparent stiffness
% including correction is printed on the final plot.
% To plot corrected curves, please replace distance Z with the following:
% Zcorr1 = Z - Fz./system_stiffness;

clear 
clc

%Declaration
slopes = [];

% Parameter input
gain = 50.67;                                                                 % Pre-calibrated force sensor gain
system_stiffness = 101.253;                                                   % Average system stiffness (extracted via Correction_of_system_stiffness.m)

name = ['Lilium_longiflorum_H2O_exine'];                                     % Choose example data (Lilium_longiflorum_H2O_exine OR Lilium_longiflorum_H2O_intine)
filename = [name '.txt'];

if exist(filename, 'file') == 2                                               % Check if file exists to prevent errors
           
    % Adjust data dimensions (initially measured in Volts)
    A = dlmread(filename);                                                    % Import data
    Fz = -(A(:,4)-mean(A(1:20,4))).*gain;                                     % Set initial force to 0 and multiply force (in Volts) with gain (see above)
    Z = 300-A(:,3)*30;                                                        % Multiply Z position (in Volts) with gain (30 um/V)                 
    
    
    % Smooth curve to reduce noise
    sizeSGolayFilt = 5;                                                       % Define factor for smooting of curve (depends on experiment, i.e. system stiffness or indentation of biological material)                             % Calculate smoothed position data (based on uncorrected Z)
    Fzsmooth_initial = sgolayfilt(Fz,1,sizeSGolayFilt);                       % Calculate smoothed force data for information on force applied by water environment (find contact to specimen)
          
    
    % Define limits to position full force-distance curve in plot                
    startindex_contact = find(Fzsmooth_initial > 3, 1);                       % Index with approximate contact (remove initial approach through water from graph)
    Zcontact = Z(startindex_contact);                                         % Position with approximate contact
    Zoffset_low = 0.75;                                                         % Offset in z-direction to see partial sensor approach prior to contact
  
    
    % Crop                                                                    
    firstindex_crop = find(Z >= (Zcontact-Zoffset_low),1,'first');            % Index for crop during loading
    lastindex_crop = find(Z >= (Zcontact-Zoffset_low),1,'last');              % Index for crop during unloading
    Znew = Z(firstindex_crop:lastindex_crop);                                 % Crop distance data
    Fznew = Fz(firstindex_crop:lastindex_crop);                               % Crop force data
    Z_crop = Znew - Znew(1);                                                  % Set initial displacement to zero
    Fz_crop = Fznew - Fznew(1);                                               % Set initial force to zero
        
    
    %Smooth curve to reduce noise (prevent error from force flactuation)
    sizeSGolayFilt = 5;                                                       % Define factor for smooting of curve (depends on experiment, i.e. system stiffness or indentation of biological material)
    Zsmooth = sgolayfilt(Z_crop,1,sizeSGolayFilt);                            % Calculate smoothed position data (based on uncorrected Z)
    Fzsmooth = sgolayfilt(Fz_crop,1,sizeSGolayFilt);                          % Calculate smoothed force data
    
    %Linearisation  
    Fzsmooth_max = max(Fzsmooth)                                              % Find maximum force of cropped curve, i.e. without influence of water during approach
    startlin = find(Fzsmooth > Fzsmooth_max-4, 1);                            % Define start of linearisation
    endlin = find(Fzsmooth > Fzsmooth_max-0.5, 1);                              % Define end of linearisation (with a max force)
    P1 = polyfit(Zsmooth(startlin:endlin),Fzsmooth(startlin:endlin),1);       % Linearisation of uncorrected indentation curve (internal stiffness not considered)
    apparent_stiffness = (P1(1)*system_stiffness)/(system_stiffness-P1(1));   % Correction of slope via internal stiffness for pure apparent stiffness of biological specimen (to account for sensor deformation)


    % Plot parameters         
    width = 5.6;                                                              % Width in inches
    height = 4.2;                                                             % Height in inches
    alw = 1;                                                                  % AxesLineWidth
    fsz = 18;                                                                 % Fontsize
    lw = 1;                                                                   % LineWidth
    msz = 12;                                                                 % MarkerSize
    Z_low = 0;                                                                % Lowest Z value
    Z_high = 3;                                                               % Highest Z value
    Z_range = Z_high - Z_low;
    F_low = -1;                                                               % Lowest force value
    F_high = 11;                                                              % Highest force value
    Fz_range = F_high - F_low;
       
    
    % Plot figure
    figure(1)                                             
    plot(Z_crop,Fz_crop,Zsmooth, Fzsmooth, Zsmooth(startlin:endlin,:), polyval(P1,Zsmooth(startlin:endlin,:)), 'LineWidth',lw,'MarkerSize',msz);    
    pos = get(gcf, 'Position');
    set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]);              % Set size of graph
    set(gca, 'FontSize', fsz, 'LineWidth', alw);
    ylim([F_low F_high])
    xlim([Z_low Z_high])
    title_name = strrep(name, '_', ' ')                                       % Remove underscores for figure title
    title([title_name])                                                       % Define figure title
    xlabel('Displacement [um]')                                               % Define x label (distance)
    ylabel('Force [uN]')                                                      % Define y label (force)
    text(0.75,-0.5, ['Apparent Stiffness: '  num2str(apparent_stiffness),' N/m  ']) % Print apparent stiffness, i.e. by internal stiffness corrected slope   
    legend({'Original Curve','Smooth Curve','Linear Fit'},'Fontsize',8)       % Add legend
                         
    % Add arrow with uncorrected slope
    deltaZ=max(Z(startlin:endlin,:))-min(Z(startlin:endlin,:));               % Automatic adjustment of arrow position
    deltaF=max(polyval(P1,Z(startlin:endlin,:)))-min(polyval(P1,Z(startlin:endlin,:))); % Automatic adjustment of arrow position
    ta1 = annotation('textarrow', [(Zsmooth(startlin)-0.2+deltaZ/2)/(Z_range) (Zsmooth(startlin)-0.1+deltaZ/2)/(Z_range)], [(Fzsmooth(startlin)+deltaF)/(Fz_range) (Fzsmooth(startlin)+deltaF)/(Fz_range)]);
    ta1.String = ['Linear Fit: '  num2str(P1(1)),' N/m'];                     % Define text for for "linear fit" arrow
    ta1.HorizontalAlignment = 'center';                                       % Center the text
    ta1.FontSize = 9;                                                         % Size of text
    ta1.Color = [255/265,165/265,0];                                          % Color of arrow and text 
                         
    print([name],'-djpeg','-r300');                                           % Save graph as .png
    savefig([name '.fig'])                                                    % Save and show graph as adjustable .fig file for further analysis
    slopes = [slopes;P1(1) apparent_stiffness];                               % Save slopes of indentation curve (linear fit) as well as (corrected) apparent stiffness            
end

dlmwrite(['slopes_' name '.txt'], slopes,'delimiter', '\t','precision','%.4f','newline','pc'); % Print txt file with slopes (linear fit and apparent stiffness)