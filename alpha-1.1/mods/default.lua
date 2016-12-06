local M = {
	enemiekiler = {
		kind = "weapon",
		stats = {
			ammo = {
				method = "add",
				perlv = 1,
				perrank = 1,
				maxrank = 10
			},
			firerate = {
				method = "mult",
				perlv = 0.01,
				perrank = 0.01,
				maxrank = 10
			}
		}
	}
}

return M
