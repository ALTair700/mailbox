gen_mux = open("gen_mux.sv", "w")
package = open("mailbox_pkg.sv", "r")
i = 0
while i <= 3:
    package.readline()
    i += 1
x = package.readline()
print(x)

word_list = x.split()
num_list = []
n_numb_cpu = 0
for word in word_list:
    if word.isnumeric():
        num_list.append(int(word))
        
n_numb_cpu = num_list[0]
print(n_numb_cpu)

with open("mux_template.txt", "r") as mux_template:
    for line in mux_template:
        gen_mux.write(line)

gen_mux.write("\n\tenum logic [N_NUMB_CPU-1:0] {\n")
i = 0
while i < n_numb_cpu:
    if(i != n_numb_cpu-1):
        gen_mux.write(f"\t\tCHECK_REQ_{i},\n")
        i += 1
    else:
        gen_mux.write(f"\t\tCHECK_REQ_{i}\n")
        i += 1
gen_mux.write("\t\t} state ;\n\n\talways @(posedge clk)\n\t\tif(!rstn)\n\t\t\tbegin\n\t\t\t\tstate\t\t<=\tCHECK_REQ_0\t;\n\t\t\t\tmux_err_o\t<=\t'0\t;\n\t\t\t\tmux_req_o\t<=\t'0\t;\n\t\t\t\tmux_addr_o\t<=\t'0\t;\n\t\t\t\tmux_data_o\t<=\t'0\t;\n\t\t\t\tmux_write_o\t<=\t'0\t;\n\t\t\t\tmux_rdata_o\t<=\t'0\t;\n\t\t\t\tmux_ack_o\t<=\t'0\t;\n\t\t\t\tmux_numb_cpu_o\t<=\t'0\t;\n\t\t\tend\n\t\telse\n\t\t\tbegin\n\t\t\t\tcase(state)\n")

i = 0
while i < n_numb_cpu:
    gen_mux.write(f"\t\t\t\t\tCHECK_REQ_{i} :\n")
    gen_mux.write("\t\t\t\t\t\tbegin\n")
    gen_mux.write(f"\t\t\t\t\t\tif(req_i[{i}])\n")
    gen_mux.write("\t\t\t\t\t\t\tbegin\n")
    gen_mux.write(f"\t\t\t\t\t\t\tmux_err_o\t[{i}]\t<=\tmux_err_i\t;\n")
    gen_mux.write(f"\t\t\t\t\t\t\tmux_req_o\t\t<=\treq_i\t[{i}]\t;\n")
    gen_mux.write(f"\t\t\t\t\t\t\tmux_addr_o\t\t<=\taddr_i\t[{i}]\t;\n")
    gen_mux.write(f"\t\t\t\t\t\t\tmux_data_o\t\t<=\tdata_i\t[{i}]\t;\n")
    gen_mux.write(f"\t\t\t\t\t\t\tmux_write_o\t\t<=\twrite_i\t[{i}]\t;\n")
    gen_mux.write(f"\t\t\t\t\t\t\tmux_rdata_o\t[{i}]\t<=\trdata_i\t\t;\n")
    gen_mux.write(f"\t\t\t\t\t\t\tmux_ack_o\t[{i}]\t<=\tack_i\t[{i}]\t;\n")
    gen_mux.write(f"\t\t\t\t\t\t\tmux_numb_cpu_o\t<=\t32'd{i}\t\t;\n")
    gen_mux.write("\t\t\t\t\t\t\tend\n")
    gen_mux.write(f"\t\t\t\t\t\telse if(!ack_i[{i}])\n")
    gen_mux.write("\t\t\t\t\t\t\tbegin\n")
    gen_mux.write(f"\t\t\t\t\t\t\t\tmux_ack_o\t[{i}]\t<=\tack_i\t[{i}]\t;\n")
    gen_mux.write(f"\t\t\t\t\t\t\t\tmux_req_o\t[{i}]\t<=\t1'b0\t\t;\n")
    if(i == n_numb_cpu - 1):
        gen_mux.write("\t\t\t\t\t\t\t\tstate\t<=\tCHECK_REQ_0\t\t;\n")
    else:
        gen_mux.write(f"\t\t\t\t\t\t\t\tstate\t<=\tCHECK_REQ_{i+1}\t\t;\n")
    gen_mux.write("\t\t\t\t\t\t\tend\n")
    gen_mux.write("\t\t\t\t\t\tend\n")
    i += 1
gen_mux.write("\t\t\t\t\tdefault:\tstate\t<=\tCHECK_REQ_0\t;\n")
gen_mux.write("\t\t\t\tendcase\n")
gen_mux.write("\t\t\tend\n")
gen_mux.write("endmodule")
mux_template.close()        
gen_mux.close()
package.close()
