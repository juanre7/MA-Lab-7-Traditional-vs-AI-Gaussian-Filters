% --- 1. Setup: Load an image and add Gaussian noise ---
% Read a sample image and convert to grayscale double format
originalImage = im2double(imread('cameraman.tif'));
% Define the noise standard deviation
noiseSigma = 0.04;
% Add Gaussian noise to the image
noisyImage = imnoise(originalImage, 'gaussian', 0, noiseSigma^2);
% Display the original and noisy images
figure('Name', 'Gaussian Noise Denoising Comparison');
subplot(1, 4, 1); imshow(originalImage); title('Original Image');
subplot(1, 4, 2); imshow(noisyImage); title('Noisy Image');

% --- 2. Traditional Filter (Adaptive Wiener Filter) ---
% The Wiener filter is a traditional adaptive filter that performs well
% with additive white Gaussian noise. It adapts its smoothing level based
% on local variance, preserving edges better than a simple Gaussian blur.
% We provide the estimated noise variance for better results.
traditionalFiltered = wiener2(noisyImage, [5 5], noiseSigma^2);
% Display the result of the traditional filter
subplot(1, 4, 3); imshow(traditionalFiltered); title('Traditional (Wiener) Filter');

% --- 3. AI Filter (Pre-trained DnCNN) ---
% The pre-trained DnCNN network in MATLAB is specifically designed
% for grayscale images with Gaussian noise within a certain range.
% It automatically learns complex features to remove noise while
% preserving details.
% Load the pre-trained denoising CNN model
net = denoisingNetwork('DnCNN');
% Apply the deep learning filter
aiFiltered = denoiseImage(noisyImage, net);
% Display the result of the AI filter
subplot(1, 4, 4); imshow(aiFiltered); title('AI (DnCNN) Filter');

% --- 4. Quantitative Evaluation (PSNR and SSIM) ---
% Calculate PSNR (Peak Signal-to-Noise Ratio) and SSIM (Structural Similarity Index)
% Higher values indicate better quality.
psnrNoisy = psnr(noisyImage, originalImage);
ssimNoisy = ssim(noisyImage, originalImage);
psnrTraditional = psnr(traditionalFiltered, originalImage);
ssimTraditional = ssim(traditionalFiltered, originalImage);
psnrAI = psnr(aiFiltered, originalImage);
ssimAI = ssim(aiFiltered, originalImage);
% Display the metrics
fprintf('\n--- Image Quality Metrics Comparison ---\n');
fprintf('Method | PSNR (dB) | SSIM\n');
fprintf('----------------------|-----------|----------\n');
fprintf('Noisy Image | %8.4f | %8.4f\n', psnrNoisy, ssimNoisy);
fprintf('Traditional (Wiener) | %8.4f | %8.4f\n', psnrTraditional, ssimTraditional);
fprintf('AI (DnCNN) | %8.4f | %8.4f\n', psnrAI, ssimAI);

% --- 5. Visual Observation ---
% The output will show that the Wiener filter does a good job of smoothing,
% but the AI-based DnCNN filter typically yields higher PSNR and SSIM values
% and better visual results by preserving fine details and texture more effectively
% than traditional methods.

%%
% === Pretty figure with table and charts for the metrics ===
methods   = {'Noisy Image','Traditional (Wiener)','AI (DnCNN)'};
psnrVals  = [psnrNoisy; psnrTraditional; psnrAI];
ssimVals  = [ssimNoisy; ssimTraditional; ssimAI];

% Build a modern UI figure with a grid layout
fig = uifigure('Name','Image Quality Metrics','Color','w');
gl  = uigridlayout(fig,[2 2], ...
    'RowHeight',{'fit','1x'}, ...
    'ColumnWidth',{'1x','1x'});

% Table with the numbers
T = table(methods', psnrVals, ssimVals, ...
    'VariableNames', {'Method','PSNR_dB','SSIM'});

tbl = uitable(gl, 'Data', T, ...
    'ColumnName', {'Method','PSNR (dB)','SSIM'}, ...
    'RowStriping','on');
tbl.Layout.Row    = 1;
tbl.Layout.Column = [1 2];
tbl.FontSize      = 12;
tbl.ColumnWidth   = {'fit','fit','fit'};

% Bar chart for PSNR
ax1 = uiaxes(gl); 
ax1.Layout.Row    = 2; 
ax1.Layout.Column = 1;
b1 = bar(ax1, categorical(methods), psnrVals);
title(ax1,'PSNR (dB)');
ylabel(ax1,'dB');
grid(ax1,'on');
xt = b1.XEndPoints; yt = b1.YEndPoints;
text(ax1, xt, yt, string(round(psnrVals,2)), ...
    'HorizontalAlignment','center','VerticalAlignment','bottom');

% Bar chart for SSIM
ax2 = uiaxes(gl); 
ax2.Layout.Row    = 2; 
ax2.Layout.Column = 2;
b2 = bar(ax2, categorical(methods), ssimVals);
title(ax2,'SSIM');
ylabel(ax2,'Value');
ylim(ax2,[0 1]);
grid(ax2,'on');
xt2 = b2.XEndPoints; yt2 = b2.YEndPoints;
text(ax2, xt2, yt2, string(round(ssimVals,4)), ...
    'HorizontalAlignment','center','VerticalAlignment','bottom');
