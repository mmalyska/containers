#Spec: {
	app:  #NonEmptyString
	base: bool
	// Where the upstream project publishes what changed in a version. Each
	// image release links to it, so Renovate PRs for the image carry it.
	// `{version}` is the image version, `{previousVersion}` the version of the
	// image's previous release.
	upstream?: {
		releaseNotes: #UrlTemplate
		compare?:     #UrlTemplate
	}
	channels: [...#Channels]
}

#Channels: {
	name: #NonEmptyString
	description: #NonEmptyString
	platforms: [...#AcceptedPlatforms]
	stable: bool
	tests: {
		enabled: bool
		type?:   =~"^(cli|web)$"
	}
}

#NonEmptyString:           string & !=""
#UrlTemplate:              =~"^https://[^[:space:]]+$"
#AcceptedPlatforms:        "linux/amd64" | "linux/arm64"
