#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

preprocessed=$base/preprocessed

mkdir -p $preprocessed

mkdir -p $preprocessed/all $preprocessed/law $preprocessed/blogs

# create in-domain dev set

python3 $scripts/split-train-dev.py \
	--input-src $base/parallel/de-rm/corpus.uniq.de \
	--input-trg $base/parallel/de-rm/corpus.uniq.rm \
	--num-dev-lines 2000 \
	--output-train-src $preprocessed/law/train.de \
	--output-train-trg $preprocessed/law/train.rm \
	--output-dev-src $preprocessed/law/dev.de \
	--output-dev-trg $preprocessed/law/dev.rm

# create in-domain test set

python3 $scripts/split-train-dev.py \
        --input-src $preprocessed/law/train.de \
        --input-trg $preprocessed/law/train.rm \
        --num-dev-lines 2000 \
        --output-train-src $preprocessed/law/train.de \
        --output-train-trg $preprocessed/law/train.rm \
        --output-dev-src $preprocessed/law/test.de \
        --output-dev-trg $preprocessed/law/test.rm

# create out-of-domain test set (setting aside the rest for dev)

python3 $scripts/split-train-dev.py \
        --input-src $base/parallel/de-rm/convivenza.de \
        --input-trg $base/parallel/de-rm/convivenza.rm \
        --num-dev-lines 2000 \
        --output-train-src $preprocessed/blogs/dev.de \
        --output-train-trg $preprocessed/blogs/dev.rm \
        --output-dev-src $preprocessed/blogs/test.de \
        --output-dev-trg $preprocessed/blogs/test.rm

# create ALL domain

cat $base/parallel/de-rm/corpus.uniq.de $base/parallel/de-rm/convivenza.de > $preprocessed/all/corpus.de
cat $base/parallel/de-rm/corpus.uniq.rm $base/parallel/de-rm/convivenza.rm > $preprocessed/all/corpus.rm

# all dev set

python3 $scripts/split-train-dev.py \
        --input-src $preprocessed/all/corpus.de \
        --input-trg $preprocessed/all/corpus.rm \
        --num-dev-lines 2000 \
        --output-train-src $preprocessed/all/train.de \
        --output-train-trg $preprocessed/all/train.rm \
        --output-dev-src $preprocessed/all/dev.de \
        --output-dev-trg $preprocessed/all/dev.rm

# all test set

python3 $scripts/split-train-dev.py \
        --input-src $preprocessed/all/train.de \
        --input-trg $preprocessed/all/train.rm \
        --num-dev-lines 2000 \
        --output-train-src $preprocessed/all/train.de \
        --output-train-trg $preprocessed/all/train.rm \
        --output-dev-src $preprocessed/all/test.de \
        --output-dev-trg $preprocessed/all/test.rm

rm $preprocessed/all/corpus.de $preprocessed/all/corpus.rm

# sizes
echo "Sizes of corpora:"

for domain in all law blogs; do
    if [[ $domain != blogs ]]; then
	echo "corpus: "$domain/train
	wc -l $preprocessed/$domain/train.de $preprocessed/$domain/train.rm
    fi

    for corpus in dev test; do
      echo "corpus: "$domain/$corpus
      wc -l $preprocessed/$domain/$corpus.de $preprocessed/$domain/$corpus.rm
    done
done

# sanity checks
echo "At this point, please make sure that 1) number of lines are as expected, 2) language suffixes are correct and 3) files are parallel"

# package results

tar -czvf $base/preprocessed.tar.gz $preprocessed
