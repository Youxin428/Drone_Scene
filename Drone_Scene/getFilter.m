function [out,name] = getFilter(Fs, band)

aaa = band/Fs/2;

Path = 'filter\';
% File = dir(fullfile(Path, '*.csv'));
File = dir(fullfile(Path, '*B_1fs.csv'));
FileNames = {File.name};

name1 = char(FileNames);
filter_name = zeros(1,length(FileNames));

for ii = 1:length(FileNames)
    data1 = strsplit(name1(ii,:),'_');
    data2 = char(data1(2));
    data3 = data2(1:end-1);
    filter_name(ii) = str2double(data3);
end

min_value = abs(filter_name - aaa);
[~,index] = min(min_value);

name = [Path,char(FileNames(index))];
out = load([Path,char(FileNames(index))]);

end