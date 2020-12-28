clear
slopes = [];
gain = 50.67;                                                       % Sensor gain of pre-calibrate sensor (bough from Femto Tools)
fitforcerange = 10;                                                 % Define force range for linear fit

for i=1:5
    
name = ['glass' num2str(i)];                                        % Naming convention of glass indentations
filename = [name '.txt'];

if exist(filename, 'file') == 2                                     % To allow for automatic evaluation even if a file would be removed (e.g. through noise)
    A = dlmread(filename);                                          % Import data
    
    % Adjust dimensions (initially measured in Volts)
    Z =300- A(:,3)*30;                                              % Multiply Z position (in Volts) with gain (30 um/V)
    Fz = -((A(:,4)-mean(A(1:300,4))).*gain);                        % Set initial force to 0 and multiply force (in Volts) with gain (see above)

    
    % Linearisation
    Fmax = max(Fz);                                                 % Find maximum force for linearisation
    startfit = find(Fz > Fmax-fitforcerange, 1);                    % Define starting position for linearisation (range of 10 uN)
    endfit = find(Fz == Fmax,1);                                    % Define end position for linearisation
    P = polyfit(Z(startfit:endfit),Fz(startfit:endfit),1);          % Perform linearisation
    
    
    % Smooth curve
    sizeSGolayFilt = 51;                                            % Define factor for smooting of curve (depends on experiment, i.e. system stiffness or indentation of biological material)
    Zsmooth = sgolayfilt(Z,2,sizeSGolayFilt);                       % Calculate smoothed position data
    Fzsmooth = sgolayfilt(Fz,2,sizeSGolayFilt);                     % Calculate smoothed force data
    size = length(Fzsmooth);

    
    % Plot parameters
    width = 5.6;                                                    % Width in inches
    height = 4.2;                                                   % Height in inches
    alw = 1;                                                        % AxesLineWidth
    fsz = 18;                                                       % Fontsize
    lw = 2;                                                         % LineWidth
    msz = 12;                                                       % MarkerSize

    % Plot graph of indentation procedure (to check for possible errors)
    figure(1)
    plot(Z,Fz,Zsmooth,Fzsmooth,Z(startfit:endfit),polyval(P,Z(startfit:endfit)),'LineWidth',lw,'MarkerSize',msz);
    pos = get(gcf, 'Position');
    set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]);    % Set size of graph
    set(gca, 'FontSize', fsz, 'LineWidth', alw);
    title(['Glass slide ', num2str(i)]);                            % Set title for graph
    xlabel('Displacement (um)');                                    % Set x label (distance)
    ylabel('Force z-direction (uN)');                               % Set y label (force)
    text(9,2, ['Internal stiffness = '  num2str(P(1))])             % Print glass stiffness on graph
    print(name,'-dpng','-r300');                                    % Save graph as .png
    saveas(gcf,name,'fig')                                          % Save and show graph as adjustable .fig file for further analysis
    
    slopes = [slopes;P(1)];                                         % Save stiffness (slope) in vector
    
    end
    
end

slopesmean = mean(slopes);                                          % Calculate mean value of internal stiffness

dlmwrite(['system_stiffness.txt'], slopes,'delimiter', '\t','precision','%.2f','newline','pc');  % Print txt file with slopes (system's stiffness)