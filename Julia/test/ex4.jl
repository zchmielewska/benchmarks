using Benchmarks
using Dates
using Test
using PythonCall

pydir = joinpath(dirname(pkgdir(Benchmarks)), "Python")
os = pyimport("os")
os.chdir(pydir)

pyimport("lifelib")
pyimport("timeit")
pd = pyimport("pandas")
np = pyimport("numpy")
mx = pyimport("modelx")
pyimport("openpyxl")

ex4 = mx.read_model("CashValue_ME_EX4")
proj = ex4.Projection

@testset "Python implementation" begin
  @testset "Array shapes" begin
    # Quickly check that the Python implementation works the way we will assume later on.
    table = proj.model_point_table
    @test length(table.shape) == 2
    (npoints, nattrs) = table.shape
    @test (npoints, nattrs) == (9, 10)

    @testset "Monte-Carlo sampling" begin
      # `proj.model_point()` holds all model points duplicated with as many samples as parametrized for the Monte-Carlo estimation.
      nsamples = proj.scen_size
      @test Bool(nsamples == 1000)
      points = proj.model_point()
      @test length(points.shape) == 2
      npoints_sampled, nattrs_expanded = points.shape
      @test (npoints_sampled, nattrs_expanded) == (npoints * nsamples, 15)

      # Setting the scenario size to 1 to have only 1 sample for the Monte-Carlo estimation.
      # Since samples are flattened, it has the same effect as "disabling" the Monte-Carlo estimation.
      (; scen_size) = proj
      proj.scen_size = 1
      try
        (npoints_sampled, nattrs_expanded) = proj.model_point().shape
        @test (npoints_sampled, nattrs_expanded) == (npoints, 15)
      finally
        proj.scen_size = scen_size
      end
    end
  end
end

@testset "Importing policy sets" begin
  policies = policies_from_lifelib("ex4/model_point_table_9.csv")
  policies_py = policies_from_lifelib(proj.model_point_table)
  @test policies_py == policies_py
end

@testset "Simulation" begin
  policies = [
    PolicySet(Policy(issued_at = Month(-2)), 40),
    PolicySet(Policy(issued_at = Month(0)), 50),
    PolicySet(Policy(issued_at = Month(1)), 50),
  ]
  model = EX4(annual_lapse_rate = 0.01)
  sim = Simulation(model, policies)
  @test length(sim.active_policies) == 1
  @test length(sim.inactive_policies) == 2
  next!(sim)
  @test length(sim.active_policies) == 2
  @test length(sim.inactive_policies) == 1
  n = sum(policy_count, sim.active_policies)
  @test 89 < n < 90
  next!(sim)
  n = sum(policy_count, sim.active_policies)
  @test 139 < n < 140

  policies = policies_from_lifelib()
  sim = Simulation(model, policies)
  # All policies start at month 0, processed in the first simulation step.
  @test isempty(sim.active_policies)
  next!(sim)
  @test length(sim.active_policies) == 100_000
  n = sum(policy_count, sim.active_policies)
  @test n > 5_000_000

  policies = policies_from_lifelib("ex4/model_point_table_9.csv")
  model = EX4(annual_lapse_rate = 0.00)
  sim = Simulation(model, policies)
  simulate!(sim, 12)
  @test sum(policy_count, sim.active_policies) == 900.0

  policies = policies_from_lifelib("ex4/model_point_table_9.csv")
  model = EX4(annual_lapse_rate = 0.00)
  sim = Simulation(model, policies)
  res = Dict(:net_cashflow => 0.0)
  simulate!(sim, 121) do events
    current_net_cashflow = sum(events.account_changes; init = 0.0) do (set, change)
      policy_count(set) * change.net_changes
    end
    # println("Current net cashflow (", length(events.account_changes), " policy sets): ", current_net_cashflow)
    res[:net_cashflow] += current_net_cashflow
  end
  @test_broken res[:net_cashflow] ≈ 399477611.70743275
end;