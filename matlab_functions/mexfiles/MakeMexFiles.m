function MakeMexFiles()
files = dir('*.c');
for i=1:length(files)
    eval(['mex ',files(i).name])
end

files = dir('*.cpp');
for i=1:length(files)
    eval(['mex ',files(i).name])
end
end
