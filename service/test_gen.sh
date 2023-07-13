set -e

for i in $(seq 200)
do
	[ -d gen/Gen$i/ ] || continue
	diff <(./result/bin/yvm gen/Gen$i/TTGen$i.class 2> /dev/null) gen/Gen$i/out.txt || echo -e "failing $i\n"
done
