# LODC Works

## 概要

LOD Challengeに投稿された作品のメタデータをRDF化したデータセットです．  
LOD Challenge 2011と2012の作品をRDF化しました．  
投稿されたアイデアを利用したアプリケーションを探したり，関連するデータセットを探したりする際に利用できます．

## スキーマ

データのスキーマは[simplified_dsp.txt](https://raw.github.com/tsunagun/lodcworks/master/simplified_dsp.txt)を参照してください．

## データダウンロード

[output.n3](https://raw.github.com/tsunagun/lodcworks/master/output.n3)をダウンロードして利用してください．

## データサンプル

    <http://purl.org/net/mdlab/data/lodc/2012/a031>
        <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/net/mdlab/ns/lodc/Application> ;
        <http://purl.org/dc/terms/available> "2012" ;
        <http://purl.org/dc/terms/creator> "落合香織" ;
        <http://purl.org/dc/terms/title> "ほんのまくらー青空文庫ー" ;
        <http://purl.org/dc/terms/description> "青空文庫で公開されているデータを使って、..." ;
        <http://xmlns.com/foaf/0.1/homepage> <http://mdlab.slis.tsukuba.ac.jp/lodc2012/honnomakura/> ;
        <http://www.w3.org/2000/01/rdf-schema#seeAlso> <http://lod.sfc.keio.ac.jp/challenge2012/show_status.php?id=a031> ;
        <http://purl.org/dc/terms/relation> <http://purl.org/net/mdlab/data/lodc/2012/d035> ;
        <http://purl.org/dc/terms/license> <http://creativecommons.org/licenses/by-nc/3.0> .
