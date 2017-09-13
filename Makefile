part3a:
	@cat urls.txt | bash part3.sh

part4a:
	@cat urls2.txt | bash part3.sh

part3: part3a part3b part3c part3d part3e

part3e:
	@bash part3.sh

part3d:
	@echo '' | bash part3.sh

part3c:
	@echo 'https://gcs-streams-prod.fubo.tv/FS_Alt_2044/F2044/master.m3u8' | bash part3.sh

part3b:
	@echo 'http://gcs-streams-prod.fubo.tv/FS_Alt_2044/F2044/master.m3u8' | bash part3.sh

check:
	@diff -uw fubo.json part2.json

part2:
	@bash part2.sh part2.json

part1:
	@bash part1.sh part1.json

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
