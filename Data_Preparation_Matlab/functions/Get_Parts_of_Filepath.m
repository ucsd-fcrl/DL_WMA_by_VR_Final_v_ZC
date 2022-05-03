function [dirname,basename] = Get_Parts_of_Filepath(file)
[dirname,name,ext] = fileparts(file);
basename = [name,ext];
