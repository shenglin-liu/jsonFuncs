# jsonFuncs
Some bash functions for parsing JSON files

## Usage
### To view the structure of the variables in the json file.
`get_json_struc $json_file`
### Reformat the json file to a tab-delimited fashion. It's convenient for extracting values.
`get_json_data $json_file`
### Get a set of values (Corrected P-values for all branches in this case) from the json file.
`get_json_values $json_file “branch attributes:0:*:Corrected P-value”`
### Get multiple sets of values (all branch attributes for all branches in this case) from the json file.
`get_json_values $json_file “branch attributes:0:*:*”`
### Get multiple sets of values (all branch attributes for all branches in this case) from the json file and present them as a matrix.
`get_json_values $json_file “branch attributes:0:*:*” | 3col2mat`
