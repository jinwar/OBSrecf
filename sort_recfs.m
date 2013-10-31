function recfs_out = sort_recfs(recfs)

	evlas = [recfs.evla];
	evlos = [recfs.evlo];
	dists = distance(evlas,evlos,recfs(1).stla,recfs(1).stlo);
	ids = 1:length(dists);
	
	mat = [ids(:),dists(:)];
	mat = sortrows(mat,2);

	for ie = 1:length(recfs)
		recfs_out(ie) = recfs(mat(ie,1));
	end
end
