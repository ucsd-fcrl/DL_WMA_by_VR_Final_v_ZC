function [new_string] = Remove_prefix_suffix_in_string(string,special_character)

% this function removes the prefix and suffix (default: ', '', [, ]) in the
% string of filename/foldername
% one can always define more characters of pre and suffix in special
% character argument

char_list = ['''','"','[',']'];
char_list = [char_list special_character];

new_string = '';
for i = 1:size(string,2)
    assert =  char_list ~= string(i);
    if all(assert) == 1
        new_string = [new_string,string(i)];
        
    end
end
     
    


