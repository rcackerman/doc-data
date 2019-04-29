import datetime

with open() as r:
	with open(f'NYCOUNTY_REQUEST_{datetime.datetime.now():%Y%m%d%H%M}.csv', 'w+') as w:
		w.writelines(n for n in r.readlines() if (n != 'NYSID' and n != ' '))
