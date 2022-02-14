function [SN, ms_ids] = createWSN(nodes, sink_nodes, sink_nodes_method, dims, energy, rounds, seed)
%CREATEWSN Creation of the Wireless Sensor Network
%   This function gives the initialization of the sensor nodes, the routing
%   nodes and the base station of the wireless sensor network (WSN). It
%   also initiates the energy values and some important conditions for the
%   WSN simulation.
%
%   INPUT PARAMETERS
%   nodes - the total number of sensor and routing nodes
%   sink_nodes - the number of mobile sinks
%   dims - the dimensions of the WSN
%   energy - initial energy of the nodes (excluding the sinks - whose
%               energy are infinite).
%   seed - the random generation seed. Default: true. But you can pass a
%               new seed by assigning a numeric valid to the seed
%               parameter. If you don't want seeding, assign 'false'.
%
%   OUTPUT PARAMETERS
%   SN - all sensors nodes (including routing routes)

%% Function Default Values

if sink_nodes >= nodes
    error('The number of mobile sinks must be less than the total number of nodes')
end

if nargin < 7
    seed = true;
end

% Simulation Seed Initiation
if seed == true
    i_seed = 0;
elseif isnumeric(seed)
    i_seed = seed;
end


%% Building the sensor nodes of the WSN

SN = struct();

for i=1:nodes
        
    if seed ~= false
        rng(i_seed);
        i_seed = i_seed + 1;
    end

    SN.n(i).id = i;	% sensor's ID number
    SN.n(i).x = dims('x_min') + rand(1,1)*(dims('x_max')-dims('x_min'));	% X-axis coordinates of sensor node
    SN.n(i).y = dims('y_min') + rand(1,1)*(dims('y_max')-dims('y_min'));	% Y-axis coordinates of sensor node
    SN.n(i).E = energy;     % nodes energy levels (initially set to be equal to "ener('init')"
    SN.n(i).role = 'N';   % node acts as normal if the value is 'N', if elected as a priority node it  gets the value 'P' (initially all nodes are normal). Nodes can also be designed as sink => 'S'
    SN.n(i).sn_visits = 0; % number of times visited by the sink nodes
    SN.n(i).cluster = 0;	% the cluster which a node belongs to
    SN.n(i).cond = 'A';	% States the current condition of the node. when the node is operational (i.e. alive) its value = 'A' and when dead, value = 'D'
    SN.n(i).rop = 0;	% number of rounds node was operational
    
    SN.n(i).col = "r"; % node color when plotting
    SN.n(i).size = 20; % marker size when plotting
    SN.n(i).alpha = (4/25)*(2.5^4).^(SN.n(i).E); % the opacity when plotting
    
    SN.n(i).Xs = []; % All positional values through the simulation
    SN.n(i).Ys = []; % All positional values through the simulation
    SN.n(i).ALPHAs = zeros(1, rounds); % All corresponding energy values through the simulation
    
end

%% Building the mobile sinks

ms_ids = zeros(1, sink_nodes); % Initializing array of mobile sink IDs

for i=1:sink_nodes

    if sink_nodes > 1 && strcmp(sink_nodes_method, 'random')
        
        if seed ~= false
            rng(i_seed);
            i_seed = i_seed + 1;
        end
        
        x = dims('x_min') + rand(1,1)*(dims('x_max')-dims('x_min'));
        y = dims('y_min') + rand(1,1)*(dims('y_max')-dims('y_min'));
    elseif sink_nodes > 1 && ( strcmp(sink_nodes_method, 'even_confined') || strcmp(sink_nodes_method, 'even_nonconfined') )
        if seed ~= false
            rng(i_seed);
            i_seed = i_seed + 1;
        end
        
        clust_angle = 2*pi/sink_nodes;
        
        pos = 0;
        while pos ~= i
            x = dims('x_min') + rand(1,1)*(dims('x_max')-dims('x_min'));
            y = dims('y_min') + rand(1,1)*(dims('y_max')-dims('y_min'));
            
            x_rel = x - dims('x_max')/2;
            y_rel = y - dims('y_max')/2;

            if x_rel >= 0 && y_rel >= 0
               reg = atan(x_rel/y_rel)/clust_angle;
            elseif x_rel < 0
               reg = ( atan(x_rel/y_rel) + pi )/clust_angle;
            elseif x_rel >= 0 && y_rel < 0
               reg = ( atan(x_rel/y_rel) + 2*pi )/clust_angle;
            end

            pos = ceil(reg);
        end
        
    elseif sink_nodes == 1
        x = dims('x_min') + 0.5*(dims('x_max')-dims('x_min'));
        y = dims('y_min') + 0.5*(dims('y_max')-dims('y_min'));
    end

    nodes_ids = [];
    dist_to_node = [];
    for j=1:length(SN.n)
        if strcmp(SN.n(j).role, 'N')
            nodes_ids(end+1) = SN.n(j).id;
            dist_to_node(end+1) = sqrt( (x - SN.n(j).x)^2 + (y - SN.n(j).y)^2 );
        end 
    end

    [~,min_id]=min(dist_to_node(:)); % finds the minimum distance of node to MS
    I = nodes_ids(min_id); % Corresponding ID

    SN.n(I).E = inf;     % nodes energy levels (initially set to be equal to "ener('init')"
    SN.n(I).role = 'S';   % node acts as normal if the value is 'N', if elected as a priority node it  gets the value 'P' (initially all nodes are normal). Nodes can also be designed as sink => 'S'
    SN.n(I).cluster = NaN;	% the cluster which a node belongs to
    
    SN.n(I).col = "k"; % node color when plotting
    SN.n(I).size = 30; % marker size when plotting
    SN.n(i).alpha = 1; % the opacity when plotting
    
    ms_ids(1, i) = I;

end

end

