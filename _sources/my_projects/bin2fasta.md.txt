# bin2fasta: Store any file as a fasta file

Have you ever wanted to combine bioinformatics and [steganography](https://en.wikipedia.org/wiki/Steganography)? No? Well, now you can.

[bin2fasta](https://github.com/kpj/bin2fasta) enables you to (reversibly) convert any file into a fasta file.
It works just as you would expect:

```bash
$ file foo.png
foo.png: PNG image data, 618 x 257, 8-bit/color RGBA, non-interlaced

$ bin2fasta -o bar.fasta foo.png
319400it [00:00, 683649.99it/s]

$ head -c50 bar.fasta
>Sequence_master
AGTTGAGGCGCCTTACTGCCGAATTAGTTAAGA

$ bin2fasta --decode -o baz.png bar.fasta
159700it [00:00, 455825.67it/s]

$ file baz.png
baz.png: PNG image data, 618 x 257, 8-bit/color RGBA, non-interlaced
```

The possibilities are endless!
