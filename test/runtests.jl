using CmdStanExtract
using Test

cnames_dummy = ["x", "y.1", "y.2", "z.1.1", "z.2.1", "z.3.1", "z.1.2", "z.2.2", "z.3.2", "k.1.1.1.1.1"]

key_to_idx = Dict(name => idx for (idx, name) in enumerate(cnames_dummy))

draws = 100
vars = length(cnames_dummy)
chains = 2
chns_dummy = randn(draws, vars, chains)

@testset "CmdStanExtract.jl" begin
    # Write your tests here.
    ex_dict = extract(chns_dummy, cnames_dummy)

    @test size(ex_dict["x"]) == (draws, chains)
    @test size(ex_dict["y"]) == (2, draws, chains)
    @test size(ex_dict["z"]) == (3, 2, draws, chains)
    @test size(ex_dict["k"]) == (1, 1, 1, 1, 1, draws, chains)

    @test ex_dict["x"][2,1] == chns_dummy[2, key_to_idx["x"], 1]
    @test ex_dict["y"][2,3,2] == chns_dummy[3, key_to_idx["y.2"], 2]
    @test ex_dict["z"][3, 1, 10, 1] == chns_dummy[10, key_to_idx["z.3.1"], 1]
    @test ex_dict["k"][1,1,1,1,1,draws,2] == chns_dummy[draws, key_to_idx["k.1.1.1.1.1"], 2]
end
