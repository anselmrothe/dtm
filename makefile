all:
	pandoc -s proposal.md --filter pandoc-fignos -o proposal.pdf
