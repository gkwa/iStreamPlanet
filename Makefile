all_check:
	@$(MAKE) bash
	@$(MAKE) check
	@$(MAKE) python
	@$(MAKE) check

bash:
	@./part2.sh part2.json | ./part3.py

python:
	@./part2.sh part2.json | ./part3.sh

check:
	@cat part2.json | jq -S . >part2.json.tmp
	@cat fubo.json | jq -S . >fubo.json.tmp
	@diff -uw fubo.json.tmp part2.json.tmp

part2:
	@./part2.sh part2.json

part1:
	@./part1.sh part1.json

pretty:
	@cat part2.json | jq . >part2.json.tmp
	@mv part2.json.tmp part2.json
	@cat part1.json | jq . >part1.json.tmp
	@mv part1.json.tmp part1.json

clean:
	@rm -rf tmp_by_distributor
	@rm -f fubo.json
	@rm -f apple.json
	@rm -f apply.json
	@rm -f *.tmp