function

% select corners

figure(112);
% imshow(I,[]);

chart = colorChecker(I);
imshow(I)
displayChart(chart);

colors = checker2colors(I, [4, 6], 'allowadjust', true, 'roisize', 20);