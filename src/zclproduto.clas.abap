CLASS zclproduto DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS zclproduto IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    TYPES: BEGIN OF ty_produto,
             cod     TYPE i,
             nome    TYPE c LENGTH 60,
             preco   TYPE p LENGTH 10 DECIMALS 2,
             estoque TYPE i,
           END OF ty_produto.


    DATA: lt_produto TYPE STANDARD TABLE OF ty_produto WITH EMPTY KEY,
          ls_produto TYPE ty_produto.

    ls_produto-cod = 1.
    ls_produto-nome = 'Notebook'.
    ls_produto-preco = 3500.
    ls_produto-estoque = 10.
    APPEND ls_produto TO lt_produto.

    ls_produto-cod = 2.
    ls_produto-nome = 'Mouse'.
    ls_produto-preco = 80.
    ls_produto-estoque = 25.
    APPEND ls_produto TO lt_produto.

    ls_produto-cod = 3.
    ls_produto-nome = 'Teclado'.
    ls_produto-preco = 150.
    ls_produto-estoque = 18.
    APPEND ls_produto TO lt_produto.

    ls_produto-cod = 4.
    ls_produto-nome = 'Monitor'.
    ls_produto-preco = 1200.
    ls_produto-estoque = 18.
    APPEND ls_produto TO lt_produto.

    APPEND VALUE ty_produto(
        cod = 5
        nome = 'Headset'
        preco = 250
        estoque = 20
    ) TO lt_produto.

    DATA lt_novos_produtos TYPE TABLE OF ty_produto.

*# é um operador de tipo implícito
*ABAP 'descobre' o tipo pelo contexto
    lt_novos_produtos = VALUE #(
        ( cod = 6
         nome = 'Webcam'
         preco = 300
         estoque = 15
        )
        ( cod = 7
          nome = 'Microfone'
          preco = 450
          estoque = 10
        )
        ( cod = 8
          nome = 'Monitor 24"'
          preco = 900
          estoque = 8
        )
    ).

    APPEND LINES OF lt_novos_produtos TO lt_produto.


*CORRESPONDING atribui campos idênticos de tabelas diferentes como iguais
*uso do MAPPING quando os campos possuem nomes diferentes
    TYPES: BEGIN OF ty_relatorio,
             codigo    TYPE i,
             descricao TYPE c LENGTH 60,
             valor     TYPE p LENGTH 10 DECIMALS 2,
           END OF ty_relatorio.

    DATA(ls_relatorio) = CORRESPONDING ty_relatorio(
                            lt_produto[ cod = 1 ]
                            MAPPING
                                codigo = cod
                                descricao = nome
                                valor = preco
                         ).


    out->write( '******* CADASTRO DE PRODUTOS *******' ).
    LOOP AT lt_produto INTO ls_produto.
      out->write( |Código: { ls_produto-cod } - Produto: { ls_produto-nome } - Preço: { ls_produto-preco } - Estoque: { ls_produto-estoque }| ).
    ENDLOOP.


    "FIELD SYMBOLS altera linha diretamente na tabela, sem copiar os dados dela como na estrutura nem usar MODIFY.
    "UNASSIGN para 'desatribuir' o <fs> à última linha processada.
    out->write( |\n******* FIELD-SYMBOLS *******| ).
    FIELD-SYMBOLS <fs_produto> TYPE ty_produto.

    READ TABLE lt_produto ASSIGNING <fs_produto> WITH KEY cod = 3.
    IF sy-subrc = 0.
      out->write( |Produto encontrado: { <fs_produto>-nome }.| ).
    ELSE.
      out->write( 'Produto não encontrado.' ).
    ENDIF.

    LOOP AT lt_produto ASSIGNING <fs_produto> WHERE cod = 2.
      <fs_produto>-estoque = 50.
    ENDLOOP.

    LOOP AT lt_produto ASSIGNING <fs_produto>.
      IF <fs_produto>-estoque < 20.
        <fs_produto>-estoque += 5.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_produto ASSIGNING <fs_produto>.
      out->write( |Código: { <fs_produto>-cod } - Produto: { <fs_produto>-nome } - Novo Estoque: { <fs_produto>-estoque }.| ).
    ENDLOOP.


*REFERENCE INTO aponta para uma linha
*Funciona como uma espécie de ponteiro
    out->write( |\n******* REFERENCE INTO *******| ).
    READ TABLE lt_produto REFERENCE INTO DATA(lr_produto) WITH KEY cod = 2.
    IF sy-subrc = 0.
      lr_produto->estoque = 75.
    ELSE.
      out->write( 'Produto não encontrado.' ).
    ENDIF.

    LOOP AT lt_produto INTO ls_produto.
      out->write( |Produto: { ls_produto-nome } - Estoque: { ls_produto-estoque }| ).
    ENDLOOP.


    out->write( |\n******* TABLE EXPRESSIONS *******| ).
    IF line_exists( lt_produto[ cod = 3 ] ).
      out->write( |Produto: { lt_produto[ cod = 3 ]-nome }.| ).
    ELSE.
      out->write( 'Produto não encontrado.' ).
    ENDIF.

    IF line_exists( lt_produto[ cod = 3 ] ).
      lt_produto[ cod = 3 ]-estoque = 50.
    ELSE.
      out->write( 'Produto não existe.' ).
    ENDIF.

    LOOP AT lt_produto INTO ls_produto.
      out->write( |Produto: { ls_produto-nome } - Estoque: { ls_produto-estoque }| ).
    ENDLOOP.


    out->write( |\n******* ORDENAÇÃO POR ESTOQUE E PREÇO *******| ).
    SORT lt_produto BY estoque ASCENDING preco DESCENDING.

    LOOP AT lt_produto INTO ls_produto.
      out->write( |Código: { ls_produto-cod } - Produto: { ls_produto-nome } - Preço: { ls_produto-preco } - Estoque: { ls_produto-estoque }| ).
    ENDLOOP.


    out->write( |\n******* CLASSIFICAÇÃO DE ESTOQUE *******| ).
    LOOP AT lt_produto INTO ls_produto.
      IF ls_produto-estoque < 15.
        out->write( |{ ls_produto-nome } - Estoque baixo.| ).
      ELSEIF ls_produto-estoque < 20.
        out->write( |{ ls_produto-nome } - Estoque moderado.| ).
      ELSE.
        out->write( |{ ls_produto-nome } - Estoque normal.| ).
      ENDIF.
    ENDLOOP.


    out->write( |\n******* ALTERAÇÃO NO ESTOQUE *******| ).
    READ TABLE lt_produto INTO ls_produto WITH KEY cod = 2.
    IF sy-subrc = 0.
      ls_produto-estoque = 12.

      MODIFY lt_produto INDEX sy-tabix FROM ls_produto TRANSPORTING estoque.

      out->write( |Produto: { ls_produto-nome } - Novo Estoque: { ls_produto-estoque }| ).
    ELSE.
      out->write( 'Produto não encontrado.' ).
    ENDIF.


    out->write( |\n******* PRODUTOS COM ESTOQUE MODERADO *******| ).
    LOOP AT lt_produto INTO ls_produto WHERE estoque >= 15 AND estoque < 20.
      out->write( |Produto: { ls_produto-nome } - Estoque: { ls_produto-estoque }.| ).
    ENDLOOP.


*Busca Binária é uma forma de procurar um valor em uma lista ordenada, eliminando metade das possibilidades a cada comparação.
    out->write( |\n******* BUSCA BINÁRIA *******| ).
    DATA lv_posicao TYPE i.

    SORT lt_produto BY cod ASCENDING.

    READ TABLE lt_produto INTO ls_produto WITH KEY cod = 3 BINARY SEARCH.
    IF sy-subrc = 0.
      lv_posicao = sy-tabix.

      out->write( |Produto encontrado: { ls_produto-nome }.| ).
      out->write( |Posição na tabela: { lv_posicao }| ).
    ELSE.
      out->write( 'Produto não encontrado.' ).
    ENDIF.


    out->write( |\n******* EXCLUSÃO DE ITEM *******| ).
    READ TABLE lt_produto INTO ls_produto WITH KEY cod = 2.
    IF sy-subrc = 0.
      DELETE lt_produto INDEX sy-tabix.
      out->write( |Produto: { ls_produto-nome } excluído.| ).
    ELSE.
      out->write( 'Produto não encontrado.' ).
    ENDIF.


*    out->write( |\n****** EXCLUSÃO DE ITENS ******| ).
*    DELETE lt_produto WHERE estoque < 15.


*    out->write( |\n****** CONTAGEM DE ITENS COM ESTOQUE BAIXO ******| ).
*    DATA lv_quantidade TYPE i.
*    lv_quantidade = 0.
*
*    LOOP AT lt_produto INTO ls_produto WHERE estoque < 15.
*        lv_quantidade += 1.
*    ENDLOOP.
*
*    out->write( |Quantidade de itens com estoque baixo: { lv_quantidade }.| ).


*TRANSPORTING NO FIELDS percorre as linhas da tabela, mas sem usar os dados dela.
    out->write( |\n****** CONTAGEM COM TRANSPORTING NO FIELDS ******| ).
    DATA lv_quantidade TYPE i.
    lv_quantidade = 0.

    LOOP AT lt_produto TRANSPORTING NO FIELDS WHERE estoque < 15.
      lv_quantidade += 1.
    ENDLOOP.

    out->write( |Quantidade de itens com estoque baixo: { lv_quantidade }.| ).


    out->write( |\n****** EXIBIÇÃO DE ITENS ******| ).
    LOOP AT lt_produto INTO ls_produto.
      out->write( |Código: { ls_produto-cod } - Produto: { ls_produto-nome } Preço: { ls_produto-preco } - Estoque: { ls_produto-estoque }.| ).
    ENDLOOP.


*Tabela ordenada pela chave
*Busca binária por padrão
    out->write( |\n****** SORTED TABLE ******| ).
    DATA lt_produto_sorted TYPE SORTED TABLE OF ty_produto WITH UNIQUE KEY cod.

    ls_produto-cod = 3.
    ls_produto-nome = 'Teclado'.
    ls_produto-preco = 150.
    ls_produto-estoque = 18.
    INSERT ls_produto INTO TABLE lt_produto_sorted.

    ls_produto-cod = 1.
    ls_produto-nome = 'Notebook'.
    ls_produto-preco = 3500.
    ls_produto-estoque = 10.
    INSERT ls_produto INTO TABLE lt_produto_sorted.

    ls_produto-cod = 4.
    ls_produto-nome = 'Monitor'.
    ls_produto-preco = 1200.
    ls_produto-estoque = 18.
    INSERT ls_produto INTO TABLE lt_produto_sorted.

    ls_produto-cod = 2.
    ls_produto-nome = 'Mouse'.
    ls_produto-preco = 80.
    ls_produto-estoque = 25.
    INSERT ls_produto INTO TABLE lt_produto_sorted.

    LOOP AT lt_produto_sorted INTO DATA(ls_produto_sorted).
      out->write( |Código: { ls_produto_sorted-cod } - Produto: { ls_produto_sorted-nome } - Preço: { ls_produto_sorted-preco } - Estoque: { ls_produto_sorted-estoque }| ).
    ENDLOOP.


*Acesso direto à chave, por meio de chave hash
*Chave sempre única
    out->write( |\n****** HASHED TABLE ******| ).
    DATA lt_produto_hashed TYPE HASHED TABLE OF ty_produto WITH UNIQUE KEY cod.

    ls_produto-cod = 3.
    ls_produto-nome = 'Teclado'.
    ls_produto-preco = 150.
    ls_produto-estoque = 18.
    INSERT ls_produto INTO TABLE lt_produto_hashed.

    ls_produto-cod = 1.
    ls_produto-nome = 'Notebook'.
    ls_produto-preco = 3500.
    ls_produto-estoque = 10.
    INSERT ls_produto INTO TABLE lt_produto_hashed.

    ls_produto-cod = 4.
    ls_produto-nome = 'Monitor'.
    ls_produto-preco = 1200.
    ls_produto-estoque = 18.
    INSERT ls_produto INTO TABLE lt_produto_hashed.

    ls_produto-cod = 2.
    ls_produto-nome = 'Mouse'.
    ls_produto-preco = 80.
    ls_produto-estoque = 25.
    INSERT ls_produto INTO TABLE lt_produto_hashed.

    LOOP AT lt_produto_hashed INTO DATA(ls_produto_hashed).
      out->write( |Código: { ls_produto_hashed-cod } - Produto: { ls_produto_hashed-nome } - Preço: { ls_produto_hashed-preco } - Estoque: { ls_produto_hashed-estoque }| ).
    ENDLOOP.









  ENDMETHOD.
ENDCLASS.
