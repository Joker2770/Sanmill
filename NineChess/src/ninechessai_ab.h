#ifndef NINECHESSAI_AB
#define NINECHESSAI_AB

#include "ninechess.h"
#include <list>

// ע�⣺NineChess�಻���̰߳�ȫ�ģ�
// ���Բ�����ai�����޸�NineChess��ľ�̬��Ա�������мǣ�


class NineChessAi_ab
{
public:
    // ����һ���ڵ�ṹ��
    struct Node{
        int value;                     // �ڵ��ֵ
        short move_;                   // �з���������ָ�ͼ�ϱ�ʾΪ�ڵ�ǰ������
        struct Node * parent;          // ���ڵ�
        list<struct Node *> children;  // �ӽڵ��б�
    };

public:
    NineChessAi_ab();
    ~NineChessAi_ab();

    void setChess(const NineChess &chess);
    void setDepth(int depth) { this->depth = depth; }
    void quit() { requiredQuit = true; }

protected:
    // �����ӽڵ�
    void buildChildren(Node *node);
    // �ӽڵ�����
    void sortChildren(Node *node);
    // ��սڵ���
    void deleteTree(Node *node);

    // ���ۺ���
    int evaluate(Node *node);
    // Alpha-Beta��֦�㷨
    int alphaBetaPruning(int depth, int alpha, int beta, Node *node);

private:
    // ԭʼģ��
    NineChess chess;
    // �����õ�ģ��
    NineChess chessTemp;

    // ���ڵ�
    Node * rootNode;

    // ��ʶ������������֦�㷨����������
    bool requiredQuit;
    // ��֦�㷨�Ĳ���
    int depth;
    // ���弫��ֵ������32λ�з����������ֵ����ֵ
    static const int infinity = 0x7fffffff;
};

#endif
