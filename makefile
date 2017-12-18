all:
	pandoc -s report.md --filter pandoc-fignos -o report.pdf
